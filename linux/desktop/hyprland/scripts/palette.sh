#!/usr/bin/env bash
set -euo pipefail

menu="$(
  cat <<'EOF'
🪟 Window: Pin/Unpin (all workspaces)
🪟 Window: Toggle floating
🪟 Window: Fullscreen (toggle)
🪟 Window: Kill active
🪟 Window: Center + Resize (1300x800)
🖥️ Hyprland: Reload config
🖥️ Hyprland: Toggle special workspace
🔒 System: Lock
🚪 System: Exit Hyprland
EOF
)"

selection="$(
  printf '%s\n' "$menu" | wofi --show dmenu --prompt 'Hypr Palette' --insensitive
)"

[[ -z "${selection}" ]] && exit 0

case "$selection" in
  "🪟 Window: Pin/Unpin (all workspaces)")
    hyprctl dispatch 'hl.dsp.window.pin()'
    ;;
  "🪟 Window: Toggle floating")
    hyprctl dispatch 'hl.dsp.window.float()'
    ;;
  "🪟 Window: Fullscreen (toggle)")
    hyprctl dispatch 'hl.dsp.window.fullscreen({mode="maximized"})'
    ;;
  "🪟 Window: Kill active")
    hyprctl dispatch 'hl.dsp.window.close()'
    ;;
  "🪟 Window: Center + Resize (1300x800)")
    hyprctl dispatch 'hl.dsp.window.center()'
    hyprctl dispatch 'hl.dsp.window.resize({x=1300,y=800,relative=false})'
    ;;
  "🖥️ Hyprland: Reload config")
    hyprctl reload
    ;;
  "🖥️ Hyprland: Toggle special workspace")
    hyprctl dispatch 'hl.dsp.workspace.toggle_special("")'
    ;;
  "🔒 System: Lock")
    ~/.config/hypr/scripts/lock.sh
    ;;
  "🚪 System: Exit Hyprland")
    hyprctl dispatch 'hl.dsp.exit()'
    ;;
  *)
    exit 0
    ;;
esac
