#!/usr/bin/env bash
set -euo pipefail

src="${1:-$HOME/dotfiles/hyprland/pam.d/hyprlock}"
dst="/etc/pam.d/hyprlock"
pam_python="/lib/security/pam_python3.so"
howdy_pam="/lib/security/howdy/pam.py"

if [[ ! -f "$src" ]]; then
  echo "missing source: $src" >&2
  exit 1
fi

if [[ ! -f "$pam_python" ]]; then
  echo "missing PAM module: $pam_python" >&2
  echo "install pam-python (pam_python3.so) first, then re-run." >&2
  exit 2
fi

if [[ ! -f "$howdy_pam" ]]; then
  echo "missing Howdy PAM script: $howdy_pam" >&2
  echo "install/configure howdy first, then re-run." >&2
  exit 3
fi

echo "Installing PAM config:"
echo "  from: $src"
echo "  to:   $dst"
echo
echo "You may be prompted for sudo password."

sudo install -m 0644 -D "$src" "$dst"
echo "OK: installed $dst"
