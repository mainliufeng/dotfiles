#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<'EOF'
Usage: ./setup.sh

Installs swww (Wayland wallpaper daemon) using the detected package manager.

Notes:
- Arch: uses pacman (or yay/paru as fallback).
- Debian/Ubuntu: tries `apt-get install swww` if available in your repo.

After install:
- Use `~/dotfiles/linux/desktop/swww/scripts/wallpaper-random.sh` to set a random wallpaper.
- (Optional) Run `~/dotfiles/linux/desktop/swww/scripts/wallpaper-rotate.sh` in background to rotate.

Environment vars:
- `SWWW_WALLPAPER_DIR` or `WALLPAPER_DIR`: wallpaper folder (default: ~/Pictures/Wallpapers etc).
- `SWWW_WALLPAPER_INTERVAL`: rotate interval seconds (default: 1800).
EOF
  exit 0
fi

echo "[swww] Installing..."

if command -v pacman >/dev/null 2>&1; then
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

Tip:
- Put wallpapers in `~/Pictures/Wallpapers`, or set `SWWW_WALLPAPER_DIR` / `WALLPAPER_DIR`.
EOF
