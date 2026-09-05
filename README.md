# dotfiles

Stow packages. `shared` is always stowed; add one Neovim package and one OS
package.

```sh
cd ~/dotfiles
stow shared nvim macos        # macOS with the custom Neovim config
stow shared lazyvim omarchy   # Omarchy with LazyVim
```

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

| Path      | Stowed | Contents                                              |
| --------- | ------ | ----------------------------------------------------- |
| `shared/` | yes    | ghostty, yazi, starship, lazygit, `.claude`            |
| `nvim/`   | choice | custom nvim config                                     |
| `lazyvim/`| choice | LazyVim config, minus `theme.lua`                      |
| `macos/`  | yes    | aerospace, nvim `theme.lua`, `.zshrc`, `.tmux.conf`    |
| `omarchy/`| yes    | Hyprland/Omarchy config, nvim `theme.lua`              |
| `macos/zsh/` | no  | sourced by `~/.zshrc` via `~/dotfiles/macos/zsh/zshrc` |
| `macos/macos-defaults.sh` | no | `defaults write` settings; run once per machine |
| `tmux/`   | no     | sourced by `~/.tmux.conf` via absolute paths           |
| `scripts/`, `kinesis/` | no | not config; run or referenced directly     |
| `.agents/` | no    | agent skills; the real files, linked into `~/.agents`  |

`.claude` at the repo root is a symlink into `shared/.claude` so the same file
serves as this repo's project instructions and as `~/.claude/CLAUDE.md`.

## Agent skills

`.agents/skills/` at the repo root holds the real skill files. Two agents read
them, by different paths:

| Consumer    | Path                | How it gets there              |
| ----------- | ------------------- | ------------------------------ |
| Codex       | `~/.agents/skills`  | one symlink, made by hand      |
| Claude Code | `~/.claude/skills`  | stowed per file, as usual      |

`shared/.claude/skills` is a symlink to `../../.agents/skills`, so stow walks
into it and links each file individually the way it does everywhere else. Adding
a skill under `.agents/skills/` and re-running `stow shared` is enough for Claude
Code; Codex picks it up with no re-stow at all.

Codex needs the hand-made symlink because it will not follow a symlinked
`SKILL.md` — a skill whose `SKILL.md` is a link is skipped silently, so stow's
`--no-folding` file links are invisible to it. It does follow symlinked
*directories*, which is why linking the whole `skills` root works and why
`.agents/` has to sit outside the stow packages.

Skills carry an optional `agents/openai.yaml` alongside `SKILL.md`. It is a Codex
extension, not part of the Agent Skills spec, and Claude Code ignores it. Note
that `allow_implicit_invocation: false` there is the Codex spelling of
`disable-model-invocation: true` in the `SKILL.md` frontmatter — set both, or the
skill stays model-invocable on one side only.

## OS differences

Config formats without conditionals (aerospace, hypr) go in the OS package.

zsh is macOS-only, so the whole shell config lives in `macos/zsh/` and no longer
branches on `uname` — the Homebrew paths, `pbcopy`, `PNPM_HOME` and the BSD
`sysreport` are inline in `macos/zsh/zshrc`. `macos/.stow-local-ignore` keeps
`macos/zsh/` out of `~`: it is sourced by absolute path from `~/.zshrc`, never
symlinked. The Linux half is recoverable with
`git log --diff-filter=D -- zsh/os/linux.zsh`.

nvim's `theme.lua` is also split by OS, for a less obvious reason. On Omarchy it
must be a symlink to `~/.local/state/omarchy/current/theme/neovim.lua`: lazy.nvim
polls that path with `fs_stat` every 2s, and `omarchy-theme-set` repointing
`current` changes the resolved mtime, which fires `LazyReload`, which is what
`omarchy-theme-hotreload.lua` listens for. A single tracked file branching on
`vim.fn.has("mac")` would never change its own mtime and would silently break
theme hot-reload. So `omarchy/` holds the symlink, `macos/` holds a plain file, and
`lazyvim/.stow-local-ignore` keeps a stray copy out of the shared package.
