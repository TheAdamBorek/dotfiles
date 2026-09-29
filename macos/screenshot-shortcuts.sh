#!/bin/bash

# Disable macOS screenshot shortcuts without changing other keyboard settings.
# Re-run after changing these shortcuts in System Settings.

set -euo pipefail

# -dict-add changes only these entries in AppleSymbolicHotKeys. Use XML so
# enabled is a boolean and the shortcut parameters are integers.
disable_screenshot_shortcut() {
  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$1" \
    "<dict><key>enabled</key><false/><key>value</key><dict><key>parameters</key><array><integer>$2</integer><integer>$3</integer><integer>$4</integer></array><key>type</key><string>standard</string></dict></dict>"
}

disable_screenshot_shortcut 28 51 20 1179648  # Shift-Command-3: screen to file
disable_screenshot_shortcut 29 51 20 1441792  # Control-Shift-Command-3: screen to clipboard
disable_screenshot_shortcut 30 52 21 1179648  # Shift-Command-4: selection to file
disable_screenshot_shortcut 31 52 21 1441792  # Control-Shift-Command-4: selection to clipboard
disable_screenshot_shortcut 181 54 22 1179648 # Shift-Command-6: Touch Bar to file
disable_screenshot_shortcut 182 54 22 1441792 # Control-Shift-Command-6: Touch Bar to clipboard
disable_screenshot_shortcut 184 53 23 1179648 # Shift-Command-5: Screenshot toolbar

# Reload the symbolic hotkeys in the current login session when available.
activate_settings=/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings
if [[ -x "$activate_settings" ]]; then
  "$activate_settings" -u
else
  echo "Log out and back in to apply screenshot shortcuts." >&2
fi
