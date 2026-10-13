#!/usr/bin/env bash

# Pull ~/dotfiles master and install its skills for Codex (~/.agents/skills)
# and Claude Code (~/.claude/skills). Safe to run again. Prints every change it
# makes; exits on a "STOP:" line when the next step could lose work.

set -euo pipefail
# comm needs git's bytewise order; en_US collation sorts hyphens differently.
export LC_ALL=C

DOTFILES="$HOME/dotfiles"

stop() {
  printf 'STOP: %s\n' "$*" >&2
  exit 1
}

# Names of the entries in a directory that resolve, one per line.
list_installed() {
  local entry
  for entry in "$1"/*; do
    if [[ -e "$entry" ]]; then basename "$entry"; fi
  done
}

skills_at() {
  git ls-tree --name-only "$1" .agents/skills/ | cut -d/ -f3
}

words() {
  local items
  items="$(paste -sd ' ' -)"
  echo "${items:-none}"
}

cd "$DOTFILES"

branch="$(git symbolic-ref --quiet --short HEAD || true)"
[[ "$branch" == master ]] || stop "~/dotfiles is on '${branch:-a detached HEAD}', not master."

old="$(git rev-parse HEAD)"
git pull --ff-only --quiet origin master ||
  stop "git pull --ff-only origin master failed; see git's message above."
new="$(git rev-parse HEAD)"
claude_before="$(list_installed "$HOME/.claude/skills")"

bash "$DOTFILES/scripts/install-agent-skills.sh"
claude_after="$(list_installed "$HOME/.claude/skills")"

echo
if [[ "$old" == "$new" ]]; then
  echo "master: already up to date at $(git rev-parse --short HEAD)"
else
  echo "master: pulled $(git rev-parse --short "$old")..$(git rev-parse --short "$new")"
  echo "new skills: $(comm -13 <(skills_at "$old") <(skills_at "$new") | words)"
  echo "removed skills: $(comm -23 <(skills_at "$old") <(skills_at "$new") | words)"
  changed="$(git diff --name-only "$old" "$new" -- .agents/skills | cut -d/ -f3 | sort -u)"
  kept="$(comm -12 <(skills_at "$old") <(skills_at "$new"))"
  echo "updated skills: $(comm -12 <(echo "$changed") <(echo "$kept") | words)"
fi
echo "newly installed for Claude Code: $(comm -13 <(echo "$claude_before") <(echo "$claude_after") | words)"

uncommitted="$(git status --short)"
if [[ -n "$uncommitted" ]]; then
  echo "uncommitted repo changes:"
  echo "$uncommitted"
fi
