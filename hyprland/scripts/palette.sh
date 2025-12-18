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
    hyprctl dispatch pin
    ;;
  "🪟 Window: Toggle floating")
    hyprctl dispatch togglefloating
    ;;
  "🪟 Window: Fullscreen (toggle)")
    hyprctl dispatch fullscreen 1
    ;;
  "🪟 Window: Kill active")
    hyprctl dispatch killactive
    ;;
  "🪟 Window: Center + Resize (1300x800)")
    hyprctl dispatch centerwindow
    hyprctl dispatch resizeactive exact 1300 800
    ;;
  "🖥️ Hyprland: Reload config")
    hyprctl reload
    ;;
  "🖥️ Hyprland: Toggle special workspace")
    hyprctl dispatch togglespecialworkspace
    ;;
  "🔒 System: Lock")
    swaylock
    ;;
  "🚪 System: Exit Hyprland")
    hyprctl dispatch exit
    ;;
  *)
    exit 0
    ;;
esac

