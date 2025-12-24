#!/usr/bin/env bash
set -euo pipefail

if ! command -v cliphist >/dev/null 2>&1; then
  echo "cliphist not found" >&2
  exit 1
fi
if ! command -v wofi >/dev/null 2>&1; then
  echo "wofi not found" >&2
  exit 1
fi
if ! command -v wl-copy >/dev/null 2>&1; then
  echo "wl-copy not found" >&2
  exit 1
fi
if ! command -v wtype >/dev/null 2>&1; then
  echo "wtype not found" >&2
  exit 1
fi

selection=$(cliphist list | wofi --dmenu --prompt "Clipboard")
if [ -z "${selection}" ]; then
  exit 0
fi

clip_id=$(printf '%s' "${selection}" | awk '{print $1}')
if [ -z "${clip_id}" ]; then
  echo "clipboard id not found" >&2
  exit 1
fi

if printf '%s' "${selection}" | rg -q 'binary data'; then
  if printf '%s' "${selection}" | rg -q '\bpng\b'; then
    mime="image/png"
  elif printf '%s' "${selection}" | rg -q '\b(jpg|jpeg)\b'; then
    mime="image/jpeg"
  elif printf '%s' "${selection}" | rg -q '\bwebp\b'; then
    mime="image/webp"
  elif printf '%s' "${selection}" | rg -q '\bgif\b'; then
    mime="image/gif"
  else
    mime="application/octet-stream"
  fi
  cliphist decode "${clip_id}" | wl-copy -t "${mime}"
else
  cliphist decode "${clip_id}" | wl-copy
fi
