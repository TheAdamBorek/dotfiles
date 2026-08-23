# dotfiles

Stow packages. `shared` is always stowed; add exactly one OS package.

```sh
cd ~/dotfiles
stow shared macos    # macOS
stow shared linux    # Omarchy / Arch
```

`.stowrc` sets `--no-folding`, so stow links individual files rather than
symlinking whole directories — safe to stow into `~/.config` alongside configs
that aren't tracked here.

## Layout

| Path      | Stowed | Contents                                              |
| --------- | ------ | ----------------------------------------------------- |
| `shared/` | yes    | nvim, ghostty, yazi, starship, lazygit, tmux entry point, `.zshrc`, `.claude` |
| `macos/`  | yes    | aerospace                                              |
| `linux/`  | yes    | Hyprland/Omarchy config (empty for now)                |
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
