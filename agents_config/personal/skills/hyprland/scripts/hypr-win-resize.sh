#!/usr/bin/env bash
set -euo pipefail

mode=""
dx=""
dy=""

usage() {
  cat <<'EOF' >&2
usage:
  hypr-win-resize --exact <width> <height>
  hypr-win-resize --delta <dx> <dy>
EOF
}

if [[ "$#" -lt 3 ]]; then
  usage
  exit 1
fi

case "$1" in
  --exact) mode="exact"; shift ;;
  --delta) mode="delta"; shift ;;
  *) usage; exit 1 ;;
esac

dx="${1:-}"
dy="${2:-}"

if [[ -z "$dx" || -z "$dy" ]]; then
  usage
  exit 1
fi

if [[ "$mode" == "exact" ]]; then
  hyprctl dispatch resizeactive exact "$dx" "$dy"
else
  hyprctl dispatch resizeactive "$dx" "$dy"
fi
