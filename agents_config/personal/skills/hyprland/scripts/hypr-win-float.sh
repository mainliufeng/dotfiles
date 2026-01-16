#!/usr/bin/env bash
set -euo pipefail

size=""
center=0

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --size) size="${2:-}"; shift 2 ;;
    --center) center=1; shift ;;
    -h|--help)
      echo "usage: hypr-win-float [--size WxH] [--center]" >&2
      exit 0
      ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

hyprctl dispatch togglefloating

if [[ -n "$size" ]]; then
  width="${size%x*}"
  height="${size#*x}"
  if [[ -n "$width" && -n "$height" ]]; then
    hyprctl dispatch resizeactive exact "$width" "$height"
  fi
fi

if [[ "$center" -eq 1 ]]; then
  hyprctl dispatch centerwindow
fi
