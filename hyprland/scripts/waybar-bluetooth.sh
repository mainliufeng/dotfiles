#!/usr/bin/env bash
set -u

json_escape() {
  sed 's/\\/\\\\/g; s/"/\\"/g'
}

if ! command -v bluetoothctl >/dev/null 2>&1; then
  printf '{"text":" N/A","tooltip":"bluetoothctl not found","class":"off"}\n'
  exit 0
fi

show_output="$(bluetoothctl show 2>/dev/null || true)"
if ! grep -q '^Controller ' <<<"$show_output"; then
  printf '{"text":" N/A","tooltip":"No Bluetooth adapter detected","class":"off"}\n'
  exit 0
fi

powered="$(awk -F': ' '/Powered:/ {print $2; exit}' <<<"$show_output")"
if [[ "$powered" != "yes" ]]; then
  printf '{"text":" Off","tooltip":"Bluetooth is off (middle click to toggle power)","class":"off"}\n'
  exit 0
fi

connected_devices="$(bluetoothctl devices Connected 2>/dev/null || true)"
connected_count="$(grep -c '^Device ' <<<"$connected_devices" || true)"

if [[ "$connected_count" -gt 0 ]]; then
  names="$(sed -E 's/^Device [^ ]+ //' <<<"$connected_devices" | paste -sd ', ' -)"
  names_escaped="$(printf '%s' "$names" | json_escape)"
  printf '{"text":" %s","tooltip":"Connected: %s","class":"on"}\n' "$connected_count" "$names_escaped"
else
  printf '{"text":" On","tooltip":"Left: manager | Right: audio menu | Middle: power","class":"on"}\n'
fi
