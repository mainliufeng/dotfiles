#!/usr/bin/env bash
set -euo pipefail

dry_run=0
match_name=""

usage() {
  cat <<'EOF'
Usage: rebind-touchpad.sh [--dry-run] [--match NAME]

Find the current I2C touchpad and rebind its I2C HID driver with pkexec.

Options:
  --dry-run     Print the detected device and command without executing it
  --match NAME  Prefer a touchpad whose name contains NAME
  -h, --help    Show this help
EOF
}

while (($#)); do
  case "$1" in
    --dry-run)
      dry_run=1
      shift
      ;;
    --match)
      match_name="${2:-}"
      if [[ -z "$match_name" ]]; then
        echo "--match requires a value" >&2
        exit 1
      fi
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

find_touchpad_event() {
  local event event_path name

  for event_path in /sys/class/input/event*; do
    [[ -e "$event_path/device/name" ]] || continue
    name="$(<"$event_path/device/name")"

    if [[ -n "$match_name" && "$name" != *"$match_name"* ]]; then
      continue
    fi

    if [[ "$name" != *Touchpad* ]]; then
      continue
    fi

    event="${event_path##*/}"
    printf '%s\n' "$event"
    return 0
  done

  return 1
}

find_i2c_parent() {
  local path base
  path="$(readlink -f "/sys/class/input/$1/device")"

  while [[ "$path" != "/" ]]; do
    base="$(basename "$path")"
    if [[ "$base" == i2c-* ]]; then
      printf '%s\n' "$base"
      return 0
    fi
    path="$(dirname "$path")"
  done

  return 1
}

detect_driver() {
  local candidate

  for candidate in i2c_hid_acpi i2c_hid_of; do
    if [[ -d "/sys/bus/i2c/drivers/$candidate/$1" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  return 1
}

event="$(find_touchpad_event)" || {
  echo "No touchpad event device found under /sys/class/input" >&2
  exit 1
}

touchpad_name="$(<"/sys/class/input/$event/device/name")"
i2c_node="$(find_i2c_parent "$event")" || {
  echo "Could not find parent i2c-* node for $event" >&2
  exit 1
}

driver="$(detect_driver "$i2c_node")" || {
  echo "Could not find an I2C HID driver bound to $i2c_node" >&2
  exit 1
}

cmd="echo $i2c_node > /sys/bus/i2c/drivers/$driver/unbind && sleep 1 && echo $i2c_node > /sys/bus/i2c/drivers/$driver/bind"

echo "Touchpad: $touchpad_name"
echo "Event: $event"
echo "I2C node: $i2c_node"
echo "Driver: $driver"

if ((dry_run)); then
  echo "Dry run: pkexec /bin/sh -lc '$cmd'"
  exit 0
fi

pkexec /bin/sh -lc "$cmd"
