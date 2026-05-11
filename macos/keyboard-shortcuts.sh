#!/usr/bin/env bash
set -euo pipefail

# Mission Control: Switch to Desktop 1/2/3 with Option+1/2/3.
# SymbolicHotKeys 118/119/120 are Desktop 1/2/3.
# Parameter format is: character code, hardware key code, modifier flags.
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 118 '{ enabled = 1; value = { parameters = (49, 18, 524288); type = standard; }; }'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 119 '{ enabled = 1; value = { parameters = (50, 19, 524288); type = standard; }; }'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 120 '{ enabled = 1; value = { parameters = (51, 20, 524288); type = standard; }; }'

# Mission Control: Move left/right a Space with Option+h/l.
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 79 '{ enabled = 1; value = { parameters = (104, 4, 524288); type = standard; }; }'
defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 81 '{ enabled = 1; value = { parameters = (108, 37, 524288); type = standard; }; }'

killall cfprefsd 2>/dev/null || true
killall Dock 2>/dev/null || true
