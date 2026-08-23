# macOS-specific shell setup. Sourced from zsh/zshrc.

if command -v brew >/dev/null; then
  BREW_PREFIX="$(brew --prefix)"
  # GNU coreutils under their unprefixed names (gls, gsed... -> ls, sed...)
  export PATH="$PATH:$BREW_PREFIX/opt/coreutils/libexec/gnubin"

  ZSH_AUTOSUGGESTIONS="$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  ZSH_SYNTAX_HIGHLIGHTING="$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi

export PNPM_HOME="$HOME/Library/pnpm"

function clipboard_copy() { pbcopy; }

function sysreport() {
  echo "=== System ==="
  top -l 1 -n 0 | grep -E "Load Avg|CPU usage|PhysMem"
  echo "\n=== Top CPU ==="
  ps -Ao pid,%cpu,%mem,comm -r | head -8
  echo "\n=== Top Memory ==="
  ps -Ao pid,%cpu,%mem,comm -m | head -8
}

# lazygit defaults to ~/Library/Application Support on macOS; use the XDG path
export LG_CONFIG_FILE="$HOME/.config/lazygit/config.yml"
