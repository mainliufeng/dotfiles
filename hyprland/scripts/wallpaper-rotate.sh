#!/usr/bin/env bash
set -euo pipefail

interval="${1:-${HYPR_WALLPAPER_INTERVAL:-1800}}"

if ! [[ "${interval}" =~ ^[0-9]+$ ]]; then
  echo "[wallpaper] Error: interval must be seconds (integer), got: ${interval}" >&2
  exit 1
fi

if (( interval < 10 )); then
  echo "[wallpaper] Error: interval too small (<10s): ${interval}" >&2
  exit 1
fi

while true; do
  sleep "${interval}"
  "${HOME}/.config/hypr/scripts/wallpaper-random.sh" >/dev/null 2>&1 || true
done

