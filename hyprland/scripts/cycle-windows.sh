#!/usr/bin/env bash
set -euo pipefail

direction="${1:-next}"
if [[ "$direction" != "next" && "$direction" != "prev" ]]; then
  direction="next"
fi

python3 - "$direction" <<'PY'
import json
import subprocess
import sys

direction = sys.argv[1] if len(sys.argv) > 1 else "next"

def hyprctl_json(*args):
    out = subprocess.check_output(["hyprctl", "-j", *args], text=True)
    return json.loads(out) if out else {}

try:
    ws = hyprctl_json("activeworkspace")
    clients = hyprctl_json("clients")
    active = hyprctl_json("activewindow")
except Exception:
    sys.exit(0)

ws_name = str(ws.get("name") or "")
ws_id = str(ws.get("id") or "")

def in_ws(client):
    w = client.get("workspace") or {}
    return str(w.get("name") or "") == ws_name or str(w.get("id") or "") == ws_id

def is_pinned(client):
    return bool(client.get("pinned"))

items = [c for c in clients if in_ws(c) and not is_pinned(c)]
if len(items) < 2:
    sys.exit(0)

def addr_key(c):
    try:
        return int(str(c.get("address") or "0"), 16)
    except Exception:
        return 0

items.sort(key=addr_key)
addresses = [c.get("address") for c in items if c.get("address")]
if not addresses:
    sys.exit(0)

active_addr = active.get("address")
try:
    idx = addresses.index(active_addr)
except ValueError:
    idx = 0

if direction == "prev":
    idx = (idx - 1) % len(addresses)
else:
    idx = (idx + 1) % len(addresses)

target = addresses[idx]
subprocess.run(["hyprctl", "dispatch", "focuswindow", f"address:{target}"], check=False)
PY
