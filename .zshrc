source ~/dotfiles/zsh/zshrc
alias claude="/Users/adamborek/.claude/local/claude"

# Safe-chain from Aikido
# Before using safe-chain you may need to unsource this and install safe-chain first.
# npm install -g @aikidosec/safe-chain
source ~/.safe-chain/scripts/init-posix.sh # Safe-chain Zsh initialization script

# pnpm
export PNPM_HOME="/Users/adamborek/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
