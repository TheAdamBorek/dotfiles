# dotfiles

Stow packages. `shared` is always stowed; add exactly one OS package.

```sh
cd ~/dotfiles
stow shared lazyvim macos    # macOS
stow shared lazyvim linux    # Omarchy / Arch
```

`.stowrc` sets `--no-folding`, so stow links individual files rather than
symlinking whole directories — safe to stow into `~/.config` alongside configs
that aren't tracked here.

## Layout

| Path      | Stowed | Contents                                              |
| --------- | ------ | ----------------------------------------------------- |
| `shared/` | yes    | ghostty, yazi, starship, lazygit, `.claude`            |
| `lazyvim/`| yes    | nvim (LazyVim), minus `theme.lua`                      |
| `macos/`  | yes    | aerospace, nvim `theme.lua`, `.zshrc`, `.tmux.conf`    |
| `linux/`  | yes    | Hyprland/Omarchy config, nvim `theme.lua`              |
| `macos/zsh/` | no  | sourced by `~/.zshrc` via `~/dotfiles/macos/zsh/zshrc` |
| `tmux/`   | no     | sourced by `~/.tmux.conf` via absolute paths           |
| `scripts/`, `kinesis/` | no | not config; run or referenced directly     |

`.claude` at the repo root is a symlink into `shared/.claude` so the same file
serves as this repo's project instructions and as `~/.claude/CLAUDE.md`.

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
theme hot-reload. So `linux/` holds the symlink, `macos/` holds a plain file, and
`lazyvim/.stow-local-ignore` keeps a stray copy out of the shared package.
