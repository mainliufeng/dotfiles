#!/usr/bin/env bash
set -euo pipefail

package="chatgpt-desktop-bin"
dry_run=0

usage() {
  cat <<'EOF'
Usage: setup.sh [--dry-run]

Install the official ChatGPT/Codex desktop app on Arch-like Linux.
The official app binary is distributed by OpenAI; the Arch package is installed
through an available AUR helper.

Options:
  --dry-run   Print the action without installing the package
  -h, --help  Show this help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) dry_run=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
done

if [[ "$(uname -s)" != "Linux" ]]; then
  echo "[chatgpt-desktop] this installer is Linux-only" >&2
  exit 1
fi

if ! grep -Eq '^(ID|ID_LIKE)=.*(arch|garuda|manjaro|endeavouros)' /etc/os-release; then
  echo "[chatgpt-desktop] only Arch-like Linux is managed by these dotfiles" >&2
  exit 1
fi

if pacman -Q "$package" >/dev/null 2>&1; then
  version="$(pacman -Q "$package" | awk '{print $2}')"
  echo "[chatgpt-desktop] official app already installed: $version"
  exit 0
fi

if command -v yay >/dev/null 2>&1; then
  installer=(yay -S --needed "$package")
elif command -v paru >/dev/null 2>&1; then
  installer=(paru -S --needed "$package")
else
  echo "[chatgpt-desktop] install yay or paru first, then rerun this script" >&2
  exit 1
fi

if [[ "$dry_run" == "1" ]]; then
  printf '[dry-run]'
  printf ' %q' "${installer[@]}"
  printf '\n'
  exit 0
fi

"${installer[@]}"
pacman -Q "$package"
