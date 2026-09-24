# dotfiles

Stow packages. `shared` is always stowed; add one Neovim package and one OS
package. `attio` is an extra opt-in package, stowed only on work machines.

For a new Mac cloned to `~/dotfiles`, run the bootstrap instead of stowing by
hand:

```sh
./macos/zsh/setup.sh
```

It installs the Homebrew dependencies, stows `shared`, `nvim` and `macos`, then
uses mise to install the global development tools.

To manage the Stow packages manually instead:

```sh
cd ~/dotfiles
stow shared nvim macos        # macOS with the custom Neovim config
stow shared lazyvim omarchy   # Omarchy with LazyVim
stow attio                    # on top of either, on an Attio machine
```

After a manual macOS Stow run, use `~/.local/bin/mise install` to install the
tools declared in the global config.

On macOS also run `./macos/macos-defaults.sh` once, then log out and back in.
It sets the preferences that live in the `defaults` database rather than in a
file, so stow has nothing to symlink.

Agent skills need one symlink stow cannot make (see "Agent skills" below):

```sh
mkdir -p ~/.agents && ln -s ~/dotfiles/.agents/skills ~/.agents/skills
```

`.stowrc` sets `--no-folding`, so stow links individual files rather than
symlinking whole directories — safe to stow into `~/.config` alongside configs
that aren't tracked here.

## Switching Neovim configs

Run either command from `~/dotfiles`. Each command removes the other package
and stows the selected one in a single transaction.

```sh
stow -D lazyvim -S nvim  # use the custom config
stow -D nvim -S lazyvim  # use LazyVim
```

The OS package stays stowed during the switch, so its matching `theme.lua`
continues to apply.

## Layout

| Path                      | Stowed | Contents                                                    |
| ------------------------- | ------ | ----------------------------------------------------------- |
| `shared/`                 | yes    | ghostty, yazi, starship, lazygit, `.claude`, `.codex`       |
| `nvim/`                   | choice | custom nvim config                                          |
| `lazyvim/`                | choice | LazyVim config, minus `theme.lua`                           |
| `macos/`                  | yes    | aerospace, mise, nvim `theme.lua`, `.zshrc`, `t3-open-nvim` |
| `omarchy/`                | yes    | Hyprland/Omarchy config, OS-specific nvim plugins           |
| `attio/`                  | opt-in | work machines only: GnuPG config for the work key           |
| `macos/zsh/`              | no     | sourced by `~/.zshrc` via `~/dotfiles/macos/zsh/zshrc`      |
| `macos/macos-defaults.sh` | no     | `defaults write` settings; run once per machine             |
| `tmux/`                   | no     | unused; kept as a backup, see "tmux" below                  |
| `scripts/`, `kinesis/`    | no     | not config; run or referenced directly                      |
| `.agents/`                | no     | agent skills; the real files, linked into `~/.agents`       |

`.claude` at the repo root is a symlink into `shared/.claude` so the same file
serves as this repo's project instructions and as `~/.claude/CLAUDE.md`.

## Agent skills

`.agents/skills/` at the repo root holds the real skill files. Two agents read
them, by different paths:

| Consumer    | Path               | How it gets there         |
| ----------- | ------------------ | ------------------------- |
| Codex       | `~/.agents/skills` | one symlink, made by hand |
| Claude Code | `~/.claude/skills` | stowed per file, as usual |

`shared/.claude/skills` is a symlink to `../../.agents/skills`, so stow walks
into it and links each file individually the way it does everywhere else. Adding
a skill under `.agents/skills/` and re-running `stow shared` is enough for Claude
Code; Codex picks it up with no re-stow at all.

Codex needs the hand-made symlink because it will not follow a symlinked
`SKILL.md` — a skill whose `SKILL.md` is a link is skipped silently, so stow's
`--no-folding` file links are invisible to it. It does follow symlinked
_directories_, which is why linking the whole `skills` root works and why
`.agents/` has to sit outside the stow packages.

Skills carry an optional `agents/openai.yaml` alongside `SKILL.md`. It is a Codex
extension, not part of the Agent Skills spec, and Claude Code ignores it. Note
that `allow_implicit_invocation: false` there is the Codex spelling of
`disable-model-invocation: true` in the `SKILL.md` frontmatter — set both, or the
skill stays model-invocable on one side only.

## Claude Code settings

`shared/.claude/settings.json` stows to `~/.claude/settings.json`: reasoning
effort, vim editor mode, fullscreen TUI, the enabled plugins and the read-deny
list that keeps agents out of keys and `.env` files.

Unlike Codex's `config.toml` this one is safe to symlink. Claude Code writes to
it only when a setting actually changes, and nothing machine-local lands in it:
project trust and history live in `~/.claude.json`, and per-project overrides in
`settings.local.json`, which `~/.gitignore` already excludes globally.

## Codex config

`~/.codex` holds two tracked files, and only one of them is a symlink.

| File                        | Stowed | Why                                       |
| --------------------------- | ------ | ----------------------------------------- |
| `shared/.codex/AGENTS.md`   | yes    | hand-written, Codex only reads it         |
| `shared/.codex/config.toml` | no     | Codex rewrites it; tracked as a reference |

Codex writes back to `config.toml` on every session: `[projects]` trust levels,
`[hooks.state]` hashes, `[tui]` nux counters, and `[marketplaces]`/`[mcp_servers]`
paths pinned to the installed ChatGPT.app build. Symlinking it into the repo
would mean a dirty worktree after every session and every project path visited
ending up in git history, so `shared/.stow-local-ignore` keeps it out of the
stow run. The tracked copy holds only the portable keys — model, personality,
approvals, desktop preferences, enabled plugins. On a new machine, let Codex
generate its own `config.toml` on first run, then merge these keys into it.

## T3 Code

T3 Code keeps its settings in `~/.t3/userdata/settings.json`, and like Codex's
`config.toml` it is not tracked: the app rewrites it with model selections,
provider instances and per-project state keyed by machine-local project IDs.

What is tracked is the logic behind its one custom action, "Open in nvim",
which opens a new Ghostty window in the thread's worktree and starts nvim
there. The script is split per OS and stows to the same path on both:

| File                              | How it opens Ghostty             |
| --------------------------------- | -------------------------------- |
| `macos/.local/bin/t3-open-nvim`   | Ghostty AppleScript API (1.3+)   |
| `omarchy/.local/bin/t3-open-nvim` | `ghostty --working-directory -e` |

On a new machine, add the action once as a default project action in T3's
settings (`defaultProjectScripts` in `settings.json`), with the same command on
both OSes:

```sh
"$HOME/.local/bin/t3-open-nvim"; exit
```

T3 runs actions in a new terminal tab whose cwd is the worktree, so the script
defaults to `$PWD`. The trailing `exit` ends that tab's shell, which makes T3
close the tab. A project with its own action list does not inherit the default
one and needs the action added to its list as well. On macOS, the first run
asks for permission to let T3 Code control Ghostty.

## GnuPG

`attio/` is stowed only on Attio work machines, on top of the usual packages:

```sh
stow attio
```

It holds the GnuPG config for the work signing key, and nothing else so far:

| File                          | Contents                                       |
| ----------------------------- | ---------------------------------------------- |
| `attio/.gnupg/gpg.conf`       | `default-key` fingerprint, `auto-key-retrieve` |
| `attio/.gnupg/dirmngr.conf`   | keyserver URL                                  |
| `attio/.gnupg/gpg-agent.conf` | cache TTLs, Homebrew `pinentry-mac` path       |

None of it is secret — two timeouts, a URL, a binary path and a public key
fingerprint. **The private key is not in this repo and must never be.** It
lives in `~/.gnupg/private-keys-v1.d/` and moves between machines out of band.

The package assumes macOS, because `gpg-agent.conf` names the Homebrew
`pinentry-mac`. That holds while Attio machines are Macs; if it stops holding,
split the file per-OS the way `theme.lua` is split rather than branching inside
it.

Two things a fresh machine needs beyond these files:

- `~/.gnupg` must be mode 0700 or gpg refuses to use it, and stow creates
  missing directories with the default umask. `setup.sh` calls
  `prepare_gnupg_home` before stowing, so a bootstrapped Mac is already fine.
  Stowing `attio` on a machine that never ran the bootstrap needs
  `mkdir -p ~/.gnupg && chmod 700 ~/.gnupg` first.
- The key passphrase lives in the macOS login keychain, put there by
  `pinentry-mac` — not in this repo. Signing is prompt-free on an existing
  machine only because that keychain entry exists; a new Mac needs the
  passphrase supplied separately.

## tmux

Replaced by herdr. Nothing stows it: `tmux/` is a plain top-level directory and
the `macos/.tmux.conf` symlink that used to link it into `~` is gone, so a fresh
`stow macos` leaves no tmux config behind.

The config is kept as a working backup. To use it again:

```sh
brew install tmux
ln -s ~/dotfiles/tmux/tmux.conf ~/.tmux.conf
git submodule update --init tmux/plugins/tpm   # if not already checked out
```

`tmux.conf` refers to its scripts, themes and tpm by absolute `$HOME/dotfiles/tmux/`
paths, so the directory has to keep that name and location for the backup to work.

## OS differences

Config formats without conditionals (aerospace, hypr) go in the OS package.

zsh is macOS-only, so the whole shell config lives in `macos/zsh/` and no longer
branches on `uname` — the Homebrew paths, `pbcopy` and the BSD `sysreport` are
inline in `macos/zsh/zshrc`. `macos/.stow-local-ignore` keeps
`macos/zsh/` out of `~`: it is sourced by absolute path from `~/.zshrc`, never
symlinked. The Linux half is recoverable with
`git log --diff-filter=D -- zsh/os/linux.zsh`.

macOS uses mise as the only development-tool version manager. Its global config
lives in `macos/.config/mise/config.toml` and supplies Node LTS, pnpm 11 plus
the latest stable Ruby, Bun and Neovim. Project configs and idiomatic version
files override those defaults after `mise activate zsh` runs.

nvim's `theme.lua` is also split by OS, for a less obvious reason. On Omarchy it
must be a symlink to `~/.local/state/omarchy/current/theme/neovim.lua`: lazy.nvim
polls that path with `fs_stat` every 2s, and `omarchy-theme-set` repointing
`current` changes the resolved mtime, which fires `LazyReload`, which is what
`omarchy-theme-hotreload.lua` listens for. A single tracked file branching on
`vim.fn.has("mac")` would never change its own mtime and would silently break
theme hot-reload. So `omarchy/` holds the symlink, `macos/` holds a plain file, and
`lazyvim/.stow-local-ignore` keeps a stray copy out of the shared package.

The Ruby LSP launcher override also lives in `omarchy/`. Mason generated its
launcher with `/usr/bin/ruby` on this machine, so the override starts it through
`mise` and enables the Rails hover fix. macOS does not load this override unless
the same problem is confirmed there.
