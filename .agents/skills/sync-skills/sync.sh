#!/usr/bin/env bash

# Pull ~/dotfiles master and install its skills for Codex (~/.agents/skills)
# and Claude Code (~/.claude/skills). Safe to run again. Prints every change it
# makes; exits on a "STOP:" line when the next step could lose work.

set -euo pipefail
# comm needs git's bytewise order; en_US collation sorts hyphens differently.
export LC_ALL=C

DOTFILES="$HOME/dotfiles"
SKILLS="$DOTFILES/.agents/skills"
CLAUDE_LINKS="$DOTFILES/shared/.claude/skills"

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

# Codex reads ~/.agents/skills, one stowed link to the whole directory. Claude
# Code needs one link per skill in shared/.claude/skills (README, "Agent skills").
tracked="$(git ls-files .agents/skills | cut -d/ -f3 | sort -u)"

for name in $tracked; do
  link="$CLAUDE_LINKS/$name"
  if [[ ! -e "$link" && ! -L "$link" ]]; then
    ln -s "../../../.agents/skills/$name" "$link"
    echo "repo: linked shared/.claude/skills/$name"
  fi
done
for link in "$CLAUDE_LINKS"/*; do
  if [[ -L "$link" && ! -e "$link" ]]; then
    rm "$link"
    echo "repo: removed dangling shared/.claude/skills/$(basename "$link")"
  fi
done

# Stow refuses targets it does not own. Replace stand-ins left by earlier
# installs, but only when they hold exactly what the repo holds.
agents_link="$HOME/.agents/skills"
if [[ -L "$agents_link" && "$(readlink "$agents_link")" != *shared/.agents/skills ]]; then
  [[ "$(realpath "$agents_link")" == "$(realpath "$SKILLS")" ]] ||
    stop "~/.agents/skills links to $(readlink "$agents_link"), not to the repo's skills."
  rm "$agents_link"
  echo "home: replaced the hand-made ~/.agents/skills link with a stowed one"
fi

for name in $tracked; do
  copy="$HOME/.claude/skills/$name"
  if [[ ! -d "$copy" || -L "$copy" ]]; then continue; fi
  differences="$(diff -rq "$copy" "$SKILLS/$name" || true)"
  [[ -z "$differences" ]] ||
    stop "~/.claude/skills/$name is a copy that differs from the repo:"$'\n'"$differences"
  rm -rf "$copy"
  echo "home: removed ~/.claude/skills/$name, a copy identical to the repo"
done

stow shared || stop "stow shared refused; see the conflicts above."

# Links stow made for skills the repo has since dropped.
for link in "$HOME/.claude/skills"/*; do
  if [[ -L "$link" && ! -e "$link" && "$(readlink "$link")" == *dotfiles/shared/* ]]; then
    rm "$link"
    echo "home: removed dangling ~/.claude/skills/$(basename "$link")"
  fi
done
claude_after="$(list_installed "$HOME/.claude/skills")"

missing=""
for name in $tracked; do
  [[ -f "$HOME/.agents/skills/$name/SKILL.md" ]] || missing+=" codex:$name"
  [[ -f "$HOME/.claude/skills/$name/SKILL.md" ]] || missing+=" claude:$name"
done
[[ -z "$missing" ]] || stop "not installed after stow:$missing"

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

uncommitted="$(git status --short -- shared/.claude/skills)"
if [[ -n "$uncommitted" ]]; then
  echo "uncommitted repo changes:"
  echo "$uncommitted"
fi
