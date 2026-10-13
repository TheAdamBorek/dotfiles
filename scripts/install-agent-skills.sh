#!/usr/bin/env bash

set -euo pipefail

DOTFILES="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
SKILLS="$DOTFILES/.agents/skills"
AGENTS_LINK="$HOME/.agents/skills"
CLAUDE_SKILLS="$HOME/.claude/skills"
DRY_RUN=false

case "${1:-}" in
  --dry-run) DRY_RUN=true; shift ;;
esac
[[ $# -eq 0 ]] || { echo "Usage: bash $0 [--dry-run]" >&2; exit 1; }

stop() {
  printf 'STOP: %s\n' "$*" >&2
  exit 1
}

# Legacy Stow targets may already be dangling, so realpath cannot identify them.
normalize_path() {
  local component normalized=""
  local -a components
  IFS=/ read -r -a components <<< "$1"
  for component in "${components[@]}"; do
    case "$component" in
      ''|.) ;;
      ..) normalized="${normalized%/*}" ;;
      *) normalized="$normalized/$component" ;;
    esac
  done
  printf '%s\n' "${normalized:-/}"
}

link_target() {
  local target
  target="$(readlink "$1")"
  [[ "$target" == /* ]] || target="$(dirname -- "$1")/$target"
  normalize_path "$target"
}

validate_link() {
  local link="$1" source="$2" legacy="$3" target
  if [[ -L "$link" ]]; then
    target="$(link_target "$link")"
    [[ "$target" == "$source" || "$target" == "$legacy" ]] ||
      stop "$link links to $(readlink "$link"), not to this repo's skills."
  elif [[ -e "$link" ]]; then
    stop "$link is a local file or directory; compare it with $source before replacing it."
  fi
}

run() {
  if "$DRY_RUN"; then
    printf '%q ' "$@"
    printf '\n'
  else
    "$@"
  fi
}

install_link() {
  local link="$1" source="$2"
  if [[ -L "$link" && "$(readlink "$link")" == "$source" ]]; then return; fi
  run ln -sfn "$source" "$link"
  printf 'linked: %s -> %s\n' "$link" "$source"
}

[[ -d "$SKILLS" ]] || stop "Missing skill source: $SKILLS"
for directory in "$HOME/.agents" "$HOME/.claude" "$CLAUDE_SKILLS"; do
  [[ ! -e "$directory" || -d "$directory" ]] || stop "$directory is not a directory."
done
[[ ! -L "$CLAUDE_SKILLS" ]] ||
  stop "$CLAUDE_SKILLS must be a real directory so Claude's synced skills stay separate."

# Validate every destination before changing any links.
validate_link "$AGENTS_LINK" "$SKILLS" "$DOTFILES/shared/.agents/skills"
count=0
for skill in "$SKILLS"/*; do
  [[ -f "$skill/SKILL.md" ]] || continue
  name="${skill##*/}"
  case "$name" in
    [sS][yY][nN][cC][eE][dD]) stop "The skill name '$name' is reserved by Claude Code." ;;
  esac
  validate_link "$CLAUDE_SKILLS/$name" "$skill" "$DOTFILES/shared/.claude/skills/$name"
  count=$((count + 1))
done
[[ "$count" -gt 0 ]] || stop "No skills found in $SKILLS"

run mkdir -p "$HOME/.agents" "$CLAUDE_SKILLS"
install_link "$AGENTS_LINK" "$SKILLS"
for skill in "$SKILLS"/*; do
  [[ -f "$skill/SKILL.md" ]] || continue
  install_link "$CLAUDE_SKILLS/${skill##*/}" "$skill"
done

# Only remove links owned by this installer or the previous Stow layout.
for link in "$CLAUDE_SKILLS"/*; do
  [[ -L "$link" ]] || continue
  name="${link##*/}"
  target="$(link_target "$link")"
  if [[ "$target" == "$SKILLS/$name" || "$target" == "$DOTFILES/shared/.claude/skills/$name" ]]; then
    if [[ ! -f "$SKILLS/$name/SKILL.md" ]]; then
      run rm "$link"
      printf 'removed obsolete link: %s\n' "$link"
    fi
  fi
done

if "$DRY_RUN"; then
  printf 'Preview complete: %s skills for Codex and Claude Code.\n' "$count"
else
  for skill in "$SKILLS"/*; do
    [[ -f "$skill/SKILL.md" ]] || continue
    [[ -f "$AGENTS_LINK/${skill##*/}/SKILL.md" && -f "$CLAUDE_SKILLS/${skill##*/}/SKILL.md" ]] ||
      stop "Skill ${skill##*/} is missing after installation."
  done
  printf 'Installed %s skills for Codex and Claude Code.\n' "$count"
fi
