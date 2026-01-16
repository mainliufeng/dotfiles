#!/usr/bin/env bash
set -euo pipefail

if ! command -v wofi >/dev/null 2>&1; then
  echo "wofi not installed" >&2
  exit 1
fi

selection="$(
  python - <<'PY' | wofi --show dmenu --prompt "Window"
import json
import subprocess

clients = json.loads(subprocess.check_output(["hyprctl", "-j", "clients"]))
for c in clients:
    addr = c.get("address", "")
    ws = c.get("workspace", {}).get("name", "")
    klass = c.get("class", "")
    title = c.get("title", "")
    print(f"{ws} | {klass} | {title} | {addr}")
PY
)"

if [[ -z "$selection" ]]; then
  exit 0
fi

addr="${selection##* | }"
if [[ -n "$addr" ]]; then
  hyprctl dispatch focuswindow "address:${addr}"
fi
