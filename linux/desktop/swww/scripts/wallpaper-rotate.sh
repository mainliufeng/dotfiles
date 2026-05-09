#!/usr/bin/env bash
set -euo pipefail

interval="${1:-${SWWW_WALLPAPER_INTERVAL:-${HYPR_WALLPAPER_INTERVAL:-1800}}}"

if ! [[ "${interval}" =~ ^[0-9]+$ ]]; then
  echo "[wallpaper] Error: interval must be seconds (integer), got: ${interval}" >&2
  exit 1
fi

if (( interval < 10 )); then
  echo "[wallpaper] Error: interval too small (<10s): ${interval}" >&2
  exit 1
fi

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

while true; do
  sleep "${interval}"
  "${script_dir}/wallpaper-random.sh" >/dev/null 2>&1 || true
done

