source ~/dotfiles/macos/zsh/zshrc

# pnpm global bin (pnpm 11+)
export PNPM_HOME="${PNPM_HOME:-$HOME/Library/pnpm}"
export PATH="$PNPM_HOME/bin:$PATH"
