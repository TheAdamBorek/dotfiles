#!/bin/bash
# Grid (BSP-ish) auto-layout for AeroSpace.
#
# AeroSpace tiles a workspace as one flat row, so every new window shrinks all
# the others: 3 windows = 3 columns of 1/3, 4 windows = 4 columns of 1/4.
# This script is run from [[on-window-detected]] and reshapes the workspace
# into columns of two instead:
#
#   1 window   full screen
#   2 windows  two halves
#   3 windows  1/2 + two 1/4 (the first window keeps its half)
#   4 windows  2x2 grid
#   5 windows  1/3 + two 1/6 + two 1/6
#   6 windows  3x2 grid
#
# The new window always ends up in the last column, at the bottom.
#
# How: flatten the workspace tree into a flat row, walk the new window to the
# far end, then 'join-with' adjacent pairs. AeroSpace's enable-normalization-
# opposite-orientation-for-nested-containers turns each joined pair into a
# split perpendicular to the row by itself, so there is no orientation
# bookkeeping here.
#
# Two properties of the AeroSpace CLI shape the rest of the script:
#
#   * 'list-windows' returns windows grouped by application, NOT in layout
#     order, and no format variable exposes a window's place in the tree. The
#     on-screen order has to be recovered from window frames, which AeroSpace
#     only keeps meaningful while the workspace is visible - windows of a
#     hidden workspace are all parked at the same off-screen point. For a
#     hidden workspace the script therefore imposes its own order instead of
#     reading one, which is free of visual cost precisely because nobody is
#     looking at it.
#   * each CLI invocation costs ~0.25s, so all reads and all writes are batched
#     into single 'aerospace eval' calls.
#
# Workspaces whose root layout is accordion are left alone, as are floating
# windows. DRY=1 prints the batch instead of running it. The last run is
# traced to $TMPDIR/aerospace-bsp-grid.log.

set -u

# 'horizontal' stacks pairs into columns (new windows appear on the right).
# 'vertical' stacks pairs into rows (new windows appear at the bottom) - the
# better choice for a portrait monitor.
AXIS=${BSP_AXIS:-horizontal}
case "$AXIS" in
  horizontal) dir=right ;;
  vertical) dir=down ;;
  *) echo "bsp-grid: BSP_AXIS must be horizontal or vertical, got '$AXIS'" >&2; exit 1 ;;
esac

AEROSPACE=$(command -v aerospace || echo /opt/homebrew/bin/aerospace)
LOG=${TMPDIR:-/tmp}/aerospace-bsp-grid.log

log() { printf '%s\n' "$*" >>"$LOG"; }
q() { "$AEROSPACE" "$@" 2>/dev/null; }

new_window=${AEROSPACE_WINDOW_ID:-}

# One read for everything: which workspace the new window landed in (an earlier
# callback may have moved it), that workspace's root layout and visibility, and
# its tiling windows.
state=$(q list-windows --all --format \
  '%{window-id}%{tab}%{workspace}%{tab}%{window-parent-container-layout}%{tab}%{workspace-root-container-layout}%{tab}%{workspace-is-visible}')

if [ -n "$new_window" ]; then
  ws=$(printf '%s\n' "$state" | awk -F'\t' -v id="$new_window" '$1 == id { print $2; exit }')
else
  ws=${AEROSPACE_FOCUSED_WORKSPACE:-$(q list-workspaces --focused)}
fi
[ -n "$ws" ] || exit 0

rows=$(printf '%s\n' "$state" | awk -F'\t' -v ws="$ws" '$2 == ws')
root_layout=$(printf '%s\n' "$rows" | awk -F'\t' 'NR == 1 { print $4 }')
visible=$(printf '%s\n' "$rows" | awk -F'\t' 'NR == 1 { print $5 }')

: >"$LOG"
log "$(date +%T) workspace $ws root=$root_layout visible=$visible axis=$AXIS new=$new_window"

# Only touch tiled workspaces. Accordion is a deliberate user choice.
case "$root_layout" in
  h_tiles | v_tiles) ;;
  *) log "skipped: root layout is $root_layout"; exit 0 ;;
esac

ids=$(printf '%s\n' "$rows" | awk -F'\t' '$3 ~ /_tiles$/ { print $1 }')
count=$(printf '%s' "$ids" | grep -c .)
if [ "$count" -lt 2 ]; then
  log "skipped: $count tiling window(s)"
  exit 0
fi

# Read the on-screen order from window frames, sorted along the row's axis.
# 'debug-windows' prints '<bundle-id>.<window-id> ||| "AXFrame" : ...' lines,
# the first one per window being the window itself.
order=
if [ "$visible" = "true" ]; then
  batch=$(printf '%s\n' "$ids" | awk '{ printf "%sdebug-windows --window-id %s", (NR > 1 ? " ; " : ""), $1 }')
  order=$(q eval "$batch" | awk -v primary="$root_layout" '
    /"AXFrame" : "<AXValue/ {
      n = split($1, path, ".")
      id = path[n]
      if (seen[id]++) next
      match($0, /x:-?[0-9.]+/); x = substr($0, RSTART + 2, RLENGTH - 2) + 0
      match($0, /y:-?[0-9.]+/); y = substr($0, RSTART + 2, RLENGTH - 2) + 0
      if (primary == "h_tiles") print x "\t" y "\t" id; else print y "\t" x "\t" id
    }' | sort -n -k1,1 -k2,2 | cut -f3)
  # Frames are unusable if any window did not report one.
  [ "$(printf '%s' "$order" | grep -c .)" -eq "$count" ] || order=
fi

if [ -n "$order" ]; then
  log "on-screen order: $(echo $order)"
  impose_all=
else
  # No usable frames: pick an order and enforce it window by window below.
  order=$ids
  impose_all=1
  log "no frames (hidden workspace), imposing order: $(echo $ids)"
fi

# The newcomer goes last so it lands in the final column.
if [ -n "$new_window" ] && printf '%s\n' "$order" | grep -qx "$new_window"; then
  index=$(printf '%s\n' "$order" | grep -nx "$new_window" | cut -d: -f1)
  order=$(printf '%s\n' "$order" | grep -vx "$new_window"; printf '%s\n' "$new_window")
  steps=$((count - index))
else
  index=
  steps=0
fi
log "final order: $(echo $order)"

# Serialize: two windows opening at once would interleave their rebuilds.
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

# Build one batch of mutations. Pinning the root axis matters: joining the only
# pair of a 2-window workspace would leave the root with a single child, which
# enable-normalization-flatten-containers collapses into the root and flips the
# whole workspace 90 degrees. The join is skipped at 2 windows for that reason,
# and the axis is re-pinned every run in case it happened by another route.
push() {
  n=$2
  while [ "$n" -gt 0 ]; do
    batch="$batch ; move --window-id $1 --boundaries workspace --boundaries-action stop $dir"
    n=$((n - 1))
  done
}

batch="flatten-workspace-tree --workspace $ws ; layout --workspace $ws --root $AXIS"

if [ -n "$impose_all" ]; then
  # Pushing each window to the far end in turn leaves the row in exactly that
  # order, whatever it was to begin with.
  for id in $order; do push "$id" $((count - 1)); done
elif [ "$steps" -gt 0 ]; then
  push "$new_window" "$steps"
fi

# Pair the row up. An odd count leaves the first window as a column of its own,
# so the window that had half the screen keeps it.
if [ "$count" -gt 2 ]; then
  set -- $order
  [ $((count % 2)) -eq 1 ] && shift
  while [ "$#" -ge 2 ]; do
    batch="$batch ; join-with --window-id $1 $dir"
    shift 2
  done
fi

if [ -n "${DRY:-}" ]; then
  printf '%s\n' "$batch" | tr ';' '\n' | sed 's/^ */  aerospace /'
  exit 0
fi

out=$("$AEROSPACE" eval "$batch" 2>&1)
status=$?
log "batch: $batch"
log "eval -> $status${out:+ | $out}"
