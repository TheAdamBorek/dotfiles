# Linux (Omarchy/Arch) specific shell setup. Sourced from zsh/zshrc.

# Distros disagree on where the zsh plugin packages land; take the first hit.
for _dir in /usr/share/zsh/plugins /usr/share; do
  [ -z "$ZSH_AUTOSUGGESTIONS" ] && [ -f "$_dir/zsh-autosuggestions/zsh-autosuggestions.zsh" ] \
    && ZSH_AUTOSUGGESTIONS="$_dir/zsh-autosuggestions/zsh-autosuggestions.zsh"
  [ -z "$ZSH_SYNTAX_HIGHLIGHTING" ] && [ -f "$_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] \
    && ZSH_SYNTAX_HIGHLIGHTING="$_dir/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
done
unset _dir

export PNPM_HOME="$HOME/.local/share/pnpm"

# Hyprland is Wayland; wl-copy comes from wl-clipboard. xclip is the X11 fallback.
if command -v wl-copy >/dev/null; then
  function clipboard_copy() { wl-copy; }
elif command -v xclip >/dev/null; then
  function clipboard_copy() { xclip -selection clipboard; }
else
  function clipboard_copy() { cat >/dev/null; }
fi

function sysreport() {
  echo "=== System ==="
  uptime
  free -h | grep -E "Mem|Swap"
  echo "\n=== Top CPU ==="
  ps -eo pid,pcpu,pmem,comm --sort=-pcpu | head -8
  echo "\n=== Top Memory ==="
  ps -eo pid,pcpu,pmem,comm --sort=-pmem | head -8
}
