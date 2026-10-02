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

The tracked zsh config is split into `zsh/zshenv` (environment variables),
`zsh/zprofile` (PATH) and `zsh/zshrc` (interactive setup). These files are
not stowed. Setup makes `~/.zshenv`, `~/.zprofile` and `~/.zshrc` regular,
machine-local files that source them. An existing file keeps its content and
only gains the `source` line at the top, so installers can append to these
files without touching the repository.

Put machine-specific secrets in `~/.zshenv` and other device-specific
settings in `~/.zprofile` or `~/.zshrc`, below the `source` line. The tracked
zsh config does not source Bash startup files.
