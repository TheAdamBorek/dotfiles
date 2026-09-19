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

Put device-specific zsh settings in `~/.zshrc.local`. The tracked zsh config
does not source Bash startup files.
