#!/usr/bin/env bun
/**
 * nvim-plugin-audit
 *
 * Wraps `Lazy! sync` with a cooldown filter: any plugin whose new commit is
 * fresher than COOLDOWN hours is rolled back to the most recent commit older
 * than the cutoff. Catches the window where a malicious release is published
 * but not yet yanked.
 */

import { readFile, writeFile, copyFile } from "node:fs/promises";
import { existsSync } from "node:fs";
import { homedir } from "node:os";
import { join } from "node:path";

type LockEntry = { branch: string; commit: string };
type Lock = Record<string, LockEntry>;

type Action =
	| { kind: "unchanged" }
	| { kind: "new"; sha: string; ageHours: number }
	| { kind: "removed" }
	| { kind: "kept"; old: string; new: string; ageHours: number }
	| {
			kind: "cooled";
			old: string;
			new: string;
			cooled: string;
			newAgeHours: number;
			cooledAgeHours: number;
	  }
	| { kind: "error"; message: string };

type Report = { plugin: string; action: Action };

const DEFAULT_LOCK = join(homedir(), "dotfiles/.config/nvim/lazy-lock.json");
const DEFAULT_LAZY_DIR = join(homedir(), ".local/share/nvim/lazy");
const DEFAULT_COOLDOWN_HOURS = 48;

function parseArgs(argv: string[]) {
	const args = {
		cooldownHours: DEFAULT_COOLDOWN_HOURS,
		lockPath: DEFAULT_LOCK,
		lazyDir: DEFAULT_LAZY_DIR,
		skipSync: false,
		only: null as string | null,
	};
	for (let i = 0; i < argv.length; i++) {
		const a = argv[i];
		if (a === "--skip-sync") args.skipSync = true;
		else if (a === "--cooldown") args.cooldownHours = Number(argv[++i]);
		else if (a === "--lock") args.lockPath = argv[++i]!;
		else if (a === "--lazy-dir") args.lazyDir = argv[++i]!;
		else if (a === "--only") args.only = argv[++i]!;
		else if (a === "-h" || a === "--help") {
			console.log(`nvim-plugin-audit [options]

  --cooldown <hours>   minimum commit age to accept (default ${DEFAULT_COOLDOWN_HOURS})
  --skip-sync          don't run \`Lazy! sync\`; audit the current lock as-is
  --lock <path>        lazy-lock.json path (default ${DEFAULT_LOCK})
  --lazy-dir <path>    plugin install dir (default ${DEFAULT_LAZY_DIR})
  --only <plugin>      audit a single plugin by name
`);
			process.exit(0);
		} else {
			console.error(`unknown arg: ${a}`);
			process.exit(2);
		}
	}
	return args;
}

async function sh(
	cwd: string,
	cmd: string[],
): Promise<{ stdout: string; ok: boolean; stderr: string }> {
	const p = Bun.spawn(cmd, { cwd, stdout: "pipe", stderr: "pipe" });
	const [stdout, stderr] = await Promise.all([
		new Response(p.stdout).text(),
		new Response(p.stderr).text(),
	]);
	const code = await p.exited;
	return { stdout: stdout.trim(), stderr: stderr.trim(), ok: code === 0 };
}

async function commitTimestamp(
	repo: string,
	sha: string,
): Promise<number | null> {
	const r = await sh(repo, ["git", "log", "-1", "--format=%ct", sha]);
	if (!r.ok || !r.stdout) return null;
	return Number(r.stdout);
}

async function findCooledSha(
	repo: string,
	branch: string,
	cutoffEpoch: number,
): Promise<string | null> {
	const r = await sh(repo, [
		"git",
		"rev-list",
		"-1",
		`--before=${cutoffEpoch}`,
		`origin/${branch}`,
	]);
	if (r.ok && r.stdout) return r.stdout;
	const r2 = await sh(repo, [
		"git",
		"rev-list",
		"-1",
		`--before=${cutoffEpoch}`,
		branch,
	]);
	if (r2.ok && r2.stdout) return r2.stdout;
	return null;
}

async function runLazySync() {
	console.log("→ running `nvim --headless +Lazy! sync +qa` ...");
	const p = Bun.spawn(["nvim", "--headless", "+Lazy! sync", "+qa"], {
		stdout: "inherit",
		stderr: "inherit",
	});
	const code = await p.exited;
	if (code !== 0) {
		console.error(`lazy sync exited with code ${code}`);
		process.exit(1);
	}
}

function fmtAge(hours: number): string {
	if (hours < 0) return "?";
	if (hours < 1) return `${Math.round(hours * 60)}m`;
	if (hours < 48) return `${hours.toFixed(1)}h`;
	return `${(hours / 24).toFixed(1)}d`;
}

async function main() {
	const args = parseArgs(process.argv.slice(2));

	if (!existsSync(args.lockPath)) {
		console.error(`lock file not found: ${args.lockPath}`);
		process.exit(1);
	}

	const backupPath = `${args.lockPath}.audit-backup`;
	await copyFile(args.lockPath, backupPath);
	console.log(`✓ backed up lock → ${backupPath}`);

	const before: Lock = JSON.parse(await readFile(backupPath, "utf8"));

	if (!args.skipSync) await runLazySync();

	const after: Lock = JSON.parse(await readFile(args.lockPath, "utf8"));

	const now = Math.floor(Date.now() / 1000);
	const cutoff = now - args.cooldownHours * 3600;

	const names = new Set([...Object.keys(before), ...Object.keys(after)]);
	const reports: Report[] = [];
	const cooledLock: Lock = { ...after };

	for (const name of [...names].sort()) {
		if (args.only && name !== args.only) continue;
		const o = before[name];
		const n = after[name];

		if (o && !n) {
			reports.push({ plugin: name, action: { kind: "removed" } });
			continue;
		}

		const repo = join(args.lazyDir, name);

		if (!o && n) {
			const ts = existsSync(repo)
				? await commitTimestamp(repo, n.commit)
				: null;
			const age = ts ? (now - ts) / 3600 : -1;
			reports.push({
				plugin: name,
				action: { kind: "new", sha: n.commit, ageHours: age },
			});
			continue;
		}

		if (!n || !o) continue;
		if (o.commit === n.commit) {
			reports.push({ plugin: name, action: { kind: "unchanged" } });
			continue;
		}

		if (!existsSync(repo)) {
			reports.push({
				plugin: name,
				action: { kind: "error", message: `repo not found at ${repo}` },
			});
			continue;
		}

		const newTs = await commitTimestamp(repo, n.commit);
		if (newTs === null) {
			reports.push({
				plugin: name,
				action: {
					kind: "error",
					message: `cannot read commit time for ${n.commit}`,
				},
			});
			continue;
		}

		const newAge = (now - newTs) / 3600;

		if (newTs <= cutoff) {
			reports.push({
				plugin: name,
				action: {
					kind: "kept",
					old: o.commit,
					new: n.commit,
					ageHours: newAge,
				},
			});
			continue;
		}

		const cooled = await findCooledSha(repo, n.branch, cutoff);
		if (!cooled) {
			reports.push({
				plugin: name,
				action: {
					kind: "error",
					message: `no commit older than cooldown on branch ${n.branch}`,
				},
			});
			continue;
		}

		const cooledTs = (await commitTimestamp(repo, cooled)) ?? now;
		cooledLock[name] = { ...n, commit: cooled };
		reports.push({
			plugin: name,
			action: {
				kind: "cooled",
				old: o.commit,
				new: n.commit,
				cooled,
				newAgeHours: newAge,
				cooledAgeHours: (now - cooledTs) / 3600,
			},
		});
	}

	printReport(reports, args.cooldownHours);

	const anyCooled = reports.some((r) => r.action.kind === "cooled");
	if (!anyCooled) {
		console.log("\n✓ nothing to cool down; lock left as-is.");
		return;
	}

	await writeFile(args.lockPath, JSON.stringify(cooledLock, null, 2) + "\n");
	console.log(`\n✓ wrote cooled lock → ${args.lockPath}`);
	console.log(
		"  next time you open nvim, lazy will check out the cooled SHAs.",
	);
}

function printReport(reports: Report[], cooldown: number) {
	console.log(`\ncooldown: ${cooldown}h\n`);
	const changed = reports.filter((r) => r.action.kind !== "unchanged");
	if (changed.length === 0) {
		console.log("no plugin changes.");
		return;
	}
	for (const { plugin, action } of changed) {
		const short = (s: string) => s.slice(0, 7);
		switch (action.kind) {
			case "new":
				console.log(
					`+ ${plugin}  NEW  ${short(action.sha)}  age=${fmtAge(action.ageHours)}`,
				);
				break;
			case "removed":
				console.log(`- ${plugin}  REMOVED`);
				break;
			case "kept":
				console.log(
					`✓ ${plugin}  ${short(action.old)} → ${short(action.new)}  age=${fmtAge(action.ageHours)}`,
				);
				break;
			case "cooled":
				console.log(
					`⏳ ${plugin}  ${short(action.old)} → ${short(action.new)} (age=${fmtAge(action.newAgeHours)})  COOLED→ ${short(action.cooled)} (age=${fmtAge(action.cooledAgeHours)})`,
				);
				break;
			case "error":
				console.log(`! ${plugin}  ERROR: ${action.message}`);
				break;
		}
	}
}

main().catch((e) => {
	console.error(e);
	process.exit(1);
});
