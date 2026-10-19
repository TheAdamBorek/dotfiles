#!/bin/bash
set -euo pipefail

AEROSPACE=$(command -v aerospace || echo /opt/homebrew/bin/aerospace)

if [ "$#" -gt 0 ]; then
  window=$("$AEROSPACE" list-windows --all \
    --format '%{window-id} %{app-bundle-id} %{window-parent-container-layout}' |
    awk -v id="$1" '$1 == id')
else
  window=$("$AEROSPACE" list-windows --focused \
    --format '%{window-id} %{app-bundle-id} %{window-parent-container-layout}')
fi

read -r window_id app_id layout <<< "$window"
if [ "$app_id" != com.apple.iphonesimulator ]; then
  echo 'Focus a tiled Simulator window first.' >&2
  exit 1
fi
case "$layout" in
  h_tiles | v_tiles) ;;
  *) echo 'Simulator must use the tiles layout.' >&2; exit 1 ;;
esac

# Simulator can refuse the tile's requested width. Read its actual macOS frame.
# CoreGraphics and AeroSpace both measure these dimensions in screen points.
width=$(/usr/bin/swift - "$window_id" <<'SWIFT'
import CoreGraphics
import Foundation

let windowID = Int(CommandLine.arguments[1])
let windows = CGWindowListCopyWindowInfo(.optionAll, kCGNullWindowID) as? [[String: Any]] ?? []
guard let window = windows.first(where: { ($0[kCGWindowNumber as String] as? Int) == windowID }),
      let bounds = window[kCGWindowBounds as String] as? [String: Any],
      let width = bounds["Width"] as? Double,
      width.isFinite, width > 0 else {
    fputs("Cannot read Simulator window width.\n", stderr)
    exit(1)
}
print(Int(ceil(width)))
SWIFT
)

# AeroSpace's tile weights include gaps. Reserve a full gap so the fixed-width
# window fits even when it has a neighbor on both sides.
gap=$(awk '$1 == "inner.horizontal" && $2 == "=" && $3 ~ /^[0-9]+$/ { print $3; exit }' \
  "$(dirname "$0")/aerospace.toml")
if [ -z "$gap" ]; then
  echo 'Expected a numeric inner.horizontal gap in aerospace.toml.' >&2
  exit 1
fi

"$AEROSPACE" resize --window-id "$window_id" width "$((width + gap))"
