#!/usr/bin/env bash
set -euo pipefail

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  cat <<'EOF'
Usage: ./setup.sh

Installs howdy (face recognition auth) using the detected package manager.

Notes:
- Arch: requires an AUR helper (yay/paru).
- Debian/Ubuntu: uses PPA `ppa:boltgolt/howdy`.
EOF
  exit 0
fi

echo "[howdy] Installing..."

if command -v pacman >/dev/null 2>&1; then
  if command -v yay >/dev/null 2>&1; then
    yay -S --needed howdy v4l-utils xcb-util-cursor
  elif command -v paru >/dev/null 2>&1; then
    paru -S --needed howdy v4l-utils xcb-util-cursor
  else
    echo "[howdy] Error: missing AUR helper (yay/paru)."
    echo "[howdy] Install yay/paru first, then re-run this script."
    exit 1
  fi
elif command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update
  sudo apt-get install -y software-properties-common v4l-utils libxcb-cursor0
  sudo add-apt-repository -y ppa:boltgolt/howdy
  sudo apt-get update
  sudo apt-get install -y howdy
else
  echo "[howdy] Error: unsupported distro (need pacman or apt-get)."
  exit 1
fi

cat <<'EOF'

[howdy] Installed.

Next steps (manual, recommended):
1) Discover camera:
   - v4l2: `v4l2-ctl --list-devices`
   - devices: `ls -l /dev/video*`
2) Configure: `./apply-config.sh` (edit `howdy/config.ini` then apply to system)
3) Enroll: `sudo howdy add`
4) Test (GUI):
   - Some versions require root: `sudo howdy test`
   - Note: `howdy test` shows face detection only (red circle/box = face detected)
   - If sudo can't open the window on Wayland/XWayland (Hyprland, etc):
     - XWayland: `xhost +SI:localuser:root && sudo --preserve-env=DISPLAY howdy test && xhost -SI:localuser:root`
     - Wayland: `sudo --preserve-env=WAYLAND_DISPLAY,XDG_RUNTIME_DIR env QT_QPA_PLATFORM=wayland howdy test`

PAM integration warning:
- Enabling howdy in PAM can lock you out if misconfigured.
- If you proceed, keep a root TTY / SSH session open while editing `/etc/pam.d/*`.
EOF
