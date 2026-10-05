#!/bin/bash
# BSP auto-layout for AeroSpace: a new window takes half of the window that had
# focus.
#
#   1 window   full screen
#   2 windows  two halves, side by side
#   3 windows  the focused half splits top/bottom into two 1/4
#   4 windows  the focused 1/4 splits side by side into two 1/8, and so on
#
# Split directions alternate with depth, and only the focused window gives up
# space. Every other window keeps its place and size.
#
# AeroSpace does most of the work. It binds a new tiling window right after the
# most recently focused window, inside that window's parent container. This
# script then runs 'join-with' on the newcomer and its previous sibling (the
# window that had focus), which wraps the pair in a new container.
# enable-normalization-opposite-orientation-for-nested-containers gives that
# container the opposite orientation, so the splits alternate.
#
# With 2 windows there is nothing to join: the root already holds the two
# halves. Joining that pair would leave the root with a single child, which
# enable-normalization-flatten-containers collapses into the root, flipping the
# whole workspace 90 degrees.
#
# Known gap: when a floating window had focus, AeroSpace appends the newcomer to
# the end of the root container, so it gets joined with whatever node is last
# there.
#
# Workspaces whose root layout is accordion are left alone, as are floating
# windows and windows inside an accordion. DRY=1 prints the command instead of
# running it. The last run is traced to $TMPDIR/aerospace-bsp-grid.log.

set -u

AEROSPACE=$(command -v aerospace || echo /opt/homebrew/bin/aerospace)
LOG=${TMPDIR:-/tmp}/aerospace-bsp-grid.log

log() { printf '%s\n' "$*" >>"$LOG"; }
q() { "$AEROSPACE" "$@" 2>/dev/null; }

new_window=${AEROSPACE_WINDOW_ID:-}
[ -n "$new_window" ] || exit 0

# Serialize: two windows opening at once would each read the tree before the
# other one's join.
lock=${TMPDIR:-/tmp}/aerospace-bsp-grid.lock
if [ -z "${DRY:-}" ]; then
  tries=0
  while ! mkdir "$lock" 2>/dev/null; do
    # Drop a lock left behind by a killed run.
    if [ -n "$(find "$lock" -maxdepth 0 -mmin +1 2>/dev/null)" ]; then
      rmdir "$lock" 2>/dev/null
      continue
    fi
    tries=$((tries + 1))
    [ "$tries" -lt 40 ] || exit 0
    sleep 0.05
  done
  trap 'rmdir "$lock" 2>/dev/null' EXIT
fi

# One read for everything: which workspace the new window landed in (an earlier
# callback may have moved it), its parent container's layout, the workspace's
# root layout, and the layouts of the workspace's other windows.
state=$(q list-windows --all --format \
  '%{window-id}%{tab}%{workspace}%{tab}%{window-parent-container-layout}%{tab}%{workspace-root-container-layout}')

ws=$(printf '%s\n' "$state" | awk -F'\t' -v id="$new_window" '$1 == id { print $2; exit }')
[ -n "$ws" ] || exit 0

rows=$(printf '%s\n' "$state" | awk -F'\t' -v ws="$ws" '$2 == ws')
parent_layout=$(printf '%s\n' "$rows" | awk -F'\t' -v id="$new_window" '$1 == id { print $3 }')
root_layout=$(printf '%s\n' "$rows" | awk -F'\t' 'NR == 1 { print $4 }')
count=$(printf '%s\n' "$rows" | awk -F'\t' '$3 ~ /^[hv]_(tiles|accordion)$/' | grep -c .)

: >"$LOG"
log "$(date +%T) workspace $ws root=$root_layout new=$new_window parent=$parent_layout tiling=$count"

# Only touch tiled workspaces. Accordion is a deliberate user choice.
case "$root_layout" in
  h_tiles | v_tiles) ;;
  *) log "skipped: root layout is $root_layout"; exit 0 ;;
esac

# The window that had focus sits right before the newcomer along its parent's
# axis.
case "$parent_layout" in
  h_tiles) dir=left ;;
  v_tiles) dir=up ;;
  *) log "skipped: new window's parent layout is $parent_layout"; exit 0 ;;
esac

if [ "$count" -lt 3 ]; then
  log "skipped: $count tiling window(s)"
  exit 0
fi

cmd="join-with --window-id $new_window $dir"

if [ -n "${DRY:-}" ]; then
  printf '  aerospace %s\n' "$cmd"
  exit 0
fi

out=$("$AEROSPACE" $cmd 2>&1)
status=$?
log "cmd: $cmd"
log "-> $status${out:+ | $out}"
