#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/keyboard-debug"
log="$HOME/keyboard-debug/i8042-keyboard-$(date +%Y%m%d-%H%M%S).log"

echo "Writing keyboard events to $log"
echo "Leave this running until the stuck-repeat bug happens, then press Ctrl+C."
echo

stdbuf -oL libinput debug-events \
  --show-keycodes \
  --device /dev/input/by-path/platform-i8042-serio-0-event-kbd \
  2>&1 | tee "$log"
