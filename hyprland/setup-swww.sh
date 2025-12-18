#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<'EOF'
Usage: ./setup-swww.sh

Installs swww (Wayland wallpaper daemon) using the detected package manager.

Notes:
- Arch: uses pacman (or yay/paru as fallback).
- Debian/Ubuntu: tries `apt-get install swww` if available in your repo.
EOF
  exit 0
fi

echo "[swww] Installing..."

if command -v pacman >/dev/null 2>&1; then
  # Prefer pacman: swww is usually in official repos.
  if command -v sudo >/dev/null 2>&1; then
    sudo pacman -S --needed --noconfirm swww xdg-user-dirs coreutils
  else
    pacman -S --needed swww xdg-user-dirs coreutils
  fi
elif command -v yay >/dev/null 2>&1; then
  yay -S --needed swww xdg-user-dirs coreutils
elif command -v paru >/dev/null 2>&1; then
  paru -S --needed swww xdg-user-dirs coreutils
elif command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y swww xdg-user-dirs coreutils
else
  echo "[swww] Error: unsupported distro (need pacman/yay/paru/apt-get)." >&2
  exit 1
fi

cat <<'EOF'

[swww] Installed.

Hyprland config uses:
- `swww init`
- `~/.config/hypr/scripts/wallpaper-random.sh`

Tip:
- Put wallpapers in `~/Pictures/Wallpapers`, or set `HYPR_WALLPAPER_DIR`.
EOF

