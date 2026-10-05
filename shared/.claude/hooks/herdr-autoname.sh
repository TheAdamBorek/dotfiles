#!/usr/bin/env bash
# UserPromptSubmit hook: names the herdr agent after the session's first prompt,
# using Haiku in the background so the prompt isn't held up.

# HERDR_AUTONAME guards against the nested `claude -p` below re-running this hook.
[[ ${HERDR_ENV:-} == 1 && -n ${HERDR_PANE_ID:-} && -z ${HERDR_AUTONAME:-} ]] || exit 0

input=$(cat)
session_id=$(jq -r '.session_id // empty' <<<"$input")
prompt=$(jq -r '.prompt // empty' <<<"$input")
[[ -n $session_id && -n $prompt ]] || exit 0

# Slash commands say little about the task, so wait for a real prompt.
[[ $prompt == /* ]] && exit 0

marker_dir="${TMPDIR:-/tmp}/herdr-autoname"
mkdir -p "$marker_dir"
# mkdir is atomic, so only the first prompt of a session gets past this.
mkdir "$marker_dir/$session_id" 2>/dev/null || exit 0

herdr=${HERDR_BIN_PATH:-herdr}
pane=$HERDR_PANE_ID

# Anything printed to stdout would be injected into the conversation.
(
  name=$(printf '%s' "${prompt:0:2000}" | HERDR_AUTONAME=1 claude -p \
    --model haiku \
    --no-session-persistence \
    --setting-sources "" \
    --strict-mcp-config \
    --tools "" \
    --system-prompt "Name the coding task described in the user's message. Reply with only the name: 2-4 English words in lowercase kebab-case, e.g. fix-login-redirect. No quotes, no explanation." \
    | head -n1)
  # herdr only accepts names matching [a-z][a-z0-9_-]{0,31}.
  name=$(printf '%s' "$name" | iconv -f UTF-8 -t ASCII//TRANSLIT 2>/dev/null | tr '[:upper:]' '[:lower:]' \
    | tr -cs 'a-z0-9_-' '-' | sed -E 's/^[^a-z]+//; s/-+$//' | cut -c1-32 | sed -E 's/-+$//')
  [[ -n $name ]] || exit 0
  # Names must be unique among live agents.
  "$herdr" agent rename "$pane" "$name" || "$herdr" agent rename "$pane" "${name:0:29}-${pane##*p}"
) </dev/null >/dev/null 2>&1 &

exit 0
