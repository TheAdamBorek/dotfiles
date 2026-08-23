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
| `shared/` | yes    | ghostty, yazi, starship, lazygit, tmux entry point, `.zshrc`, `.claude` |
| `lazyvim/`| yes    | nvim (LazyVim), minus `theme.lua`                      |
| `macos/`  | yes    | aerospace, nvim `theme.lua`                            |
| `linux/`  | yes    | Hyprland/Omarchy config, nvim `theme.lua`              |
| `zsh/`    | no     | sourced by `~/.zshrc` via `~/dotfiles/zsh/zshrc`       |
| `tmux/`   | no     | sourced by `~/.tmux.conf` via absolute paths           |
| `scripts/`, `kinesis/` | no | not config; run or referenced directly     |

`.claude` at the repo root is a symlink into `shared/.claude` so the same file
serves as this repo's project instructions and as `~/.claude/CLAUDE.md`.

## OS differences

Shell config is a program, so it branches at runtime instead of being duplicated:
`zsh/zshrc` is shared and sources `zsh/os/darwin.zsh` or `zsh/os/linux.zsh` based
on `uname -s`. Those files own the Homebrew vs pacman paths, `pbcopy` vs `wl-copy`,
`PNPM_HOME`, and the BSD vs GNU `sysreport`.

Config formats without conditionals (aerospace, hypr) go in the OS package instead.

nvim's `theme.lua` is also split by OS, for a less obvious reason. On Omarchy it
must be a symlink to `~/.local/state/omarchy/current/theme/neovim.lua`: lazy.nvim
polls that path with `fs_stat` every 2s, and `omarchy-theme-set` repointing
`current` changes the resolved mtime, which fires `LazyReload`, which is what
`omarchy-theme-hotreload.lua` listens for. A single tracked file branching on
`vim.fn.has("mac")` would never change its own mtime and would silently break
theme hot-reload. So `linux/` holds the symlink, `macos/` holds a plain file, and
`lazyvim/.stow-local-ignore` keeps a stray copy out of the shared package.
