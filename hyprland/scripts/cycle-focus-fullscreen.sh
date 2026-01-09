#!/usr/bin/env bash
set -euo pipefail

direction="${1:-next}"
if [[ "$direction" != "next" && "$direction" != "prev" ]]; then
  direction="next"
fi

internal=0
client=0
json="$(hyprctl -j activewindow 2>/dev/null || true)"
if [[ -n "$json" ]]; then
  read -r internal client < <(
    python3 -c 'import json,sys
try:
    data=json.load(sys.stdin)
except Exception:
    sys.exit(0)
internal=data.get("fullscreen",0)
client=data.get("fullscreenClient",0)
print(f"{internal} {client}")' <<<"$json"
  ) || true
fi

target="$(
  python3 - "$direction" <<'PY' || true
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

items = [c for c in clients if in_ws(c)]
if len(items) < 2:
    sys.exit(0)

addr_to_client = {c.get("address"): c for c in items if c.get("address")}
addr_set = set(addr_to_client)
if not addr_set:
    sys.exit(0)

def pos(addr):
    c = addr_to_client.get(addr) or {}
    at = c.get("at") or [0, 0]
    x = at[0] if len(at) > 0 else 0
    y = at[1] if len(at) > 1 else 0
    return (x, y)

groups = {}
for addr, c in addr_to_client.items():
    grouped = c.get("grouped")
    if isinstance(grouped, list) and grouped:
        members = [a for a in grouped if a in addr_set]
        if not members:
            members = [addr]
        group_id = tuple(sorted(members))
        if group_id not in groups:
            groups[group_id] = members
    else:
        group_id = ("__single__", addr)
        groups[group_id] = [addr]

group_entries = []
for members in groups.values():
    group_pos = min((pos(a) for a in members), default=(0, 0))
    group_entries.append((group_pos, members))

group_entries.sort(key=lambda item: (item[0][0], item[0][1]))
addresses = [addr for _, members in group_entries for addr in members]

active_addr = active.get("address")
try:
    idx = addresses.index(active_addr)
except ValueError:
    idx = 0

if direction == "prev":
    idx = (idx - 1) % len(addresses)
else:
    idx = (idx + 1) % len(addresses)

sys.stdout.write(addresses[idx])
PY
)"

if [[ -n "$target" ]]; then
  hyprctl dispatch focuswindow "address:${target}"
fi

if [[ "$internal" =~ ^[0-3]$ ]] && [[ "$client" =~ ^[0-3]$ ]] && { [[ "$internal" != "0" ]] || [[ "$client" != "0" ]]; }; then
  hyprctl dispatch fullscreenstate "$internal" "$client" set
fi
