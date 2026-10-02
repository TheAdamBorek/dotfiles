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

link_local_zsh_file() {
  # ~/.zshenv, ~/.zprofile and ~/.zshrc stay machine-local files (secrets,
  # installer additions) that source the tracked config, so they are not
  # stowed. An existing file keeps its content and only gains the source line.
  local target="$HOME/.$1"
  local line="source ~/dotfiles/macos/zsh/$1"

  # Earlier setups stowed ~/.zshrc as a symlink into this repository.
  if [[ -L "$target" && "$(readlink "$target")" == *dotfiles/* ]]; then
    rm "$target"
  fi

  if [[ ! -f "$target" ]]; then
    printf '%s\n\n# Machine-specific settings go below. This file is not tracked in dotfiles.\n' \
      "$line" >"$target"
    return
  fi

  if grep -qxF "$line" "$target"; then
    return
  fi

  local tmp
  tmp="$(mktemp)"
  {
    echo "$line"
    echo
    cat "$target"
  } >"$tmp"
  # Write through cat so the file keeps its permissions.
  cat "$tmp" >"$target"
  rm "$tmp"
}

prepare_local_zsh_files() {
  link_local_zsh_file zshenv
  # ~/.zshenv holds machine-specific secrets.
  chmod 600 "$HOME/.zshenv"
  link_local_zsh_file zprofile
  link_local_zsh_file zshrc
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
# Before Oh My Zsh: its installer writes its own ~/.zshrc when none exists.
prepare_local_zsh_files
stow shared lazyvim macos

install_oh_my_zsh
install_mise
/bin/bash "$REPO_DIR/macos/macos-defaults.sh"

echo "Setup complete. Start a new login shell with: exec zsh -l"
echo "On an Attio machine, also run: stow attio"
