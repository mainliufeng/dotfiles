#!/usr/bin/env bash
set -euo pipefail

# Mission Control: keep Spaces in their manual order instead of MRU order.
defaults write com.apple.dock mru-spaces -bool false

# Mission Control: Switch to Desktop 1..10 with Option+1..9/0.
# SymbolicHotKeys 118..127 are Desktop 1..10.
# Parameter format is: character code, hardware key code, modifier flags.
set_desktop_hotkey() {
  local shortcut_id="$1"
  local character_code="$2"
  local key_code="$3"

  defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add "$shortcut_id" \
    "{ enabled = 1; value = { parameters = ($character_code, $key_code, 524288); type = standard; }; }"
}

set_desktop_hotkey 118 49 18
set_desktop_hotkey 119 50 19
set_desktop_hotkey 120 51 20
set_desktop_hotkey 121 52 21
set_desktop_hotkey 122 53 23
set_desktop_hotkey 123 54 22
set_desktop_hotkey 124 55 26
set_desktop_hotkey 125 56 28
set_desktop_hotkey 126 57 25
set_desktop_hotkey 127 48 29

# Mission Control: Move left/right a Space with Option+h/l.
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 79 '{ enabled = 1; value = { parameters = (104, 4, 524288); type = standard; }; }'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 81 '{ enabled = 1; value = { parameters = (108, 37, 524288); type = standard; }; }'

killall cfprefsd 2>/dev/null || true
killall Dock 2>/dev/null || true
