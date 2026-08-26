#!/bin/bash

# macOS preferences that live in the defaults database rather than in a file,
# so stow can't symlink them. Run by hand after a fresh install:
#
#   ./macos/macos-defaults.sh
#
# then log out and back in. Idempotent: every setting is an absolute write.

set -euo pipefail

# Key repeat. Both values are counts of 15ms ticks. KeyRepeat 1 is below the
# floor of the System Settings slider (which stops at 2), so touching that
# slider silently resets this — re-run the script if it ever feels sluggish.
defaults write -g KeyRepeat -int 1          # 15ms between repeats, ~66 chars/sec
defaults write -g InitialKeyRepeat -int 15  # 225ms before the repeat kicks in

# Hold a key to repeat it instead of opening the accent-character popup.
# Apps that honour this won't repeat held keys at all while it's on.
defaults write -g ApplePressAndHoldEnabled -bool false

echo "Written. Log out and back in for these to take effect everywhere."
