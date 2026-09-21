#!/usr/bin/env bash

# Bootstrap a new Mac from a clone at ~/dotfiles. The script is safe to run
# again: installers and Stow skip work that is already complete.

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)"
REPO_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/../.." && pwd)"

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "This setup script only supports macOS." >&2
  exit 1
fi

if [[ "$REPO_DIR" != "$HOME/dotfiles" ]]; then
  echo "Clone this repository to $HOME/dotfiles before running setup." >&2
  exit 1
fi

load_homebrew() {
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [[ -x /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi
}

install_homebrew() {
  load_homebrew
  if command -v brew >/dev/null 2>&1; then
    return
  fi

  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  load_homebrew

  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew was installed but is not available on PATH." >&2
    exit 1
  fi
}

install_oh_my_zsh() {
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    return
  fi

  RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
    "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

prepare_gnupg_home() {
  # The bootstrap does not stow `attio`, but it prepares the directory that
  # package targets. Stow creates missing target directories with the default
  # umask, and gpg refuses to use a homedir that is group- or world-readable,
  # so a later `stow attio` would land its configs somewhere gpg ignores.
  mkdir -p "$HOME/.gnupg"
  chmod 700 "$HOME/.gnupg"
}

install_mise() {
  if [[ ! -x "$HOME/.local/bin/mise" ]]; then
    curl -fsSL https://mise.run | sh
  fi

  "$HOME/.local/bin/mise" install
}

install_homebrew
/bin/bash "$SCRIPT_DIR/install_dependencies.sh"

cd "$REPO_DIR"
prepare_gnupg_home
stow shared nvim macos

install_oh_my_zsh
install_mise

echo "Setup complete. Start a new login shell with: exec zsh -l"
echo "On an Attio machine, also run: stow attio"
