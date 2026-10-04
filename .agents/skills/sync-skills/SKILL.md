---
name: sync-skills
description: Pull ~/dotfiles master and install its skills for Codex and Claude Code.
disable-model-invocation: true
---

# Sync skills

Pull the latest `master` of `~/dotfiles` and install every skill in `.agents/skills/` for Codex and Claude Code. The README's "Agent skills" section describes the layout this maintains.

## 1. Run the sync script

```sh
bash ~/dotfiles/.agents/skills/sync-skills/sync.sh
```

The script prints each change it makes. A `STOP:` line means the next step could lose work, so it needs the user's decision.

Done when it exits 0. On a `STOP:`, go to step 2; otherwise go to step 3.

## 2. Resolve a stop

Show the user the script's message and the evidence below, propose a fix, and wait for their answer before changing anything:

- **Not on master, or pull refused**: `git status` and `git log --oneline --left-right origin/master...HEAD`.
- **`~/.claude/skills/<name>` differs from the repo**: `diff -r` of the two. The local copy may hold edits that belong in the repo.
- **`~/.agents/skills` links elsewhere**: where it points and what that directory holds.
- **Stow conflicts**: for each target stow names, `ls -la` of it, plus a diff against the repo file when it is a regular file.

After the fix, run the script again. Done when it exits 0.

## 3. Report

Tell the user:

- each skill listed as new or newly installed, with the `description` from its `SKILL.md` frontmatter, marking the ones that set `disable-model-invocation: true` as invoke-by-name only;
- updated and removed skills;
- the uncommitted repo changes the script listed. Commit them only when the user asks.
