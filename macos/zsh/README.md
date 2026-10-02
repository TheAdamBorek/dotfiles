# Installation

Clone the repository to `~/dotfiles`, then run:

```sh
./macos/zsh/setup.sh
```

The script installs Homebrew packages, stows the macOS configuration, installs
Oh My Zsh and mise, then installs the tools declared in
`~/.config/mise/config.toml`. It can be run again after an interrupted setup.

The global mise configuration supplies Node LTS, pnpm 11 and the latest stable
Ruby, Bun and Neovim. A project's `mise.toml`, `.nvmrc`, `.node-version`,
`.ruby-version` or `package.json` can override those defaults.

Shared environment variables live in `zsh/zshenv` and PATH setup in
`zsh/zprofile`. They are not stowed: `~/.zshenv` and `~/.zprofile` stay
regular, machine-local files that source them, so installers can append to
`~/.zprofile` without touching the repository. On a new machine, add these
lines at the top of each file:

```sh
# ~/.zshenv
source ~/dotfiles/macos/zsh/zshenv

# ~/.zprofile
source ~/dotfiles/macos/zsh/zprofile
```

Put machine-specific secrets in `~/.zshenv`, below the `source` line, and
other device-specific zsh settings in `~/.zshrc.local`. The tracked zsh config
does not source Bash startup files.
