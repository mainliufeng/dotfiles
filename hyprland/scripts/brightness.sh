#!/usr/bin/env bash
set -euo pipefail

action="${1:-}"
step="${2:-5}"

if [[ "$action" != "up" && "$action" != "down" ]]; then
  echo "Usage: $(basename "$0") up|down [step_percent]" >&2
  exit 2
fi

if ! [[ "$step" =~ ^[0-9]+$ ]] || (( step <= 0 )); then
  echo "Invalid step: $step" >&2
  exit 2
fi

if command -v light >/dev/null 2>&1; then
  if [[ "$action" == "up" ]]; then
    light -A "$step"
  else
    light -U "$step"
  fi
  exit 0
fi

if command -v brightnessctl >/dev/null 2>&1; then
  if [[ "$action" == "up" ]]; then
    brightnessctl set "${step}%+"
  else
    brightnessctl set "${step}%-"
  fi
  exit 0
fi

device="$(ls -1 /sys/class/backlight 2>/dev/null | head -n 1 || true)"
if [[ -z "$device" ]]; then
  echo "No /sys/class/backlight device found" >&2
  exit 1
fi

base="/sys/class/backlight/$device"
max="$(cat "$base/max_brightness")"
cur="$(cat "$base/brightness")"

target=$(( cur + (max * step / 100) ))
if [[ "$action" == "down" ]]; then
  target=$(( cur - (max * step / 100) ))
fi

if (( target < 1 )); then target=1; fi
if (( target > max )); then target="$max"; fi

if [[ -w "$base/brightness" ]]; then
  printf '%s' "$target" > "$base/brightness"
  exit 0
fi

if command -v pkexec >/dev/null 2>&1; then
  pkexec /bin/sh -c "printf '%s' '$target' > '$base/brightness'"
  exit 0
fi

echo "No backend found to set brightness (install 'light' or 'brightnessctl', or ensure pkexec is available)" >&2
exit 1

