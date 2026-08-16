#!/bin/bash

# Installs the essential brew packages used daily. Runs non-interactively:
# already-installed packages are skipped, missing ones are installed without
# prompting. A failed install logs a warning and continues with the rest.

install_brew_package() {
  local package=$1
  if brew list --formula --cask 2>/dev/null | grep -qx "${package##*/}"; then
    echo "$package is already installed."
  else
    echo "Installing $package..."
    brew install "$package" || echo "Failed to install $package. Continuing with the next one..."
  fi
}

brew_packages=(
  "zsh-autosuggestions"                     # suggests commands as you type from history
  "zsh-syntax-highlighting"                 # colors the command line, red for invalid commands
  "ripgrep"                                 # fast recursive grep (rg), respects .gitignore
  "fzf"                                     # fuzzy finder for files, history, anything piped in
  "tmux"                                    # terminal multiplexer: panes, windows, persistent sessions
  "lazygit"                                 # terminal UI for git
  "1password-cli"                           # 1Password from the terminal (op), secrets/env injection
  "git-delta"                               # syntax-highlighted, side-by-side git diffs
  "tree-sitter-cli"                         # parser generator/CLI, used by Neovim for syntax
  "starship"                                # cross-shell prompt (the fancy prompt line)
  "llm"                                     # CLI to query LLMs from the terminal
  "jesseduffield/lazydocker/lazydocker"     # terminal UI for docker/docker-compose
  "libimobiledevice"                        # talk to iOS devices over USB (idevice* tools)
  "switchaudio-osx"                         # switch macOS audio in/out from the CLI
  "tlrc"                                    # tldr client: concise, example-first man pages
  "stow"                                    # symlink manager for dotfiles
  "lua"                                     # Lua interpreter (Neovim config, etc.)
  "eza"                                     # modern ls replacement (icons, git status, tree)
  "tmuxinator"                              # define and launch tmux layouts from YAML
  "fnm"                                     # fast Node version manager
  "bob"                                     # Neovim version manager
  "gh"                                      # GitHub CLI (PRs, issues, auth)
  # Yazi terminal file explorer and its dependencies
  "yazi"                                    # blazing-fast terminal file manager
  "ffmpegthumbnailer"                       # video thumbnails in Yazi previews
  "sevenzip"                                # 7z archive extraction/preview
  "jq"                                      # command-line JSON processor
  "poppler"                                 # PDF rendering for previews (pdftoppm etc.)
  "fd"                                      # simple, fast find replacement
  "zoxide"                                  # smarter cd that learns your most-used dirs
  "imagemagick"                             # image conversion/preview (convert, magick)
  "font-symbols-only-nerd-font"             # glyphs/icons used by eza, starship, yazi
)

for package in "${brew_packages[@]}"; do
  install_brew_package "$package"
done

echo "Installation process completed."
