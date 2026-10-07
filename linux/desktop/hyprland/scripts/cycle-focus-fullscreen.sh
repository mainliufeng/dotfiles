#!/usr/bin/env bash
set -euo pipefail

direction="${1:-next}"
if [[ "$direction" != "next" && "$direction" != "prev" ]]; then
  direction="next"
fi
mode="${2:-workspace}"
if [[ "$mode" != "workspace" && "$mode" != "group" && "$mode" != "all" ]]; then
  mode="workspace"
fi
cache_file="${XDG_RUNTIME_DIR:-/tmp}/hypr-cycle-group-${UID}.json"

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
is_fullscreen=0
if { [[ "$internal" != "0" ]] || [[ "$client" != "0" ]]; }; then
  is_fullscreen=1
fi

if [[ "$mode" == "group" ]]; then
  if [[ "$direction" == "prev" ]]; then
    hyprctl dispatch changegroupactive b || true
  else
    hyprctl dispatch changegroupactive f || true
  fi
  CACHE_FILE="$cache_file" python3 - <<'PY' || true
import json
import os
import subprocess

cache_file = os.environ.get("CACHE_FILE")
if not cache_file:
    raise SystemExit(0)

def hyprctl_json(*args):
    out = subprocess.check_output(["hyprctl", "-j", *args], text=True)
    return json.loads(out) if out else {}

try:
    clients = hyprctl_json("clients")
    active = hyprctl_json("activewindow")
except Exception:
    raise SystemExit(0)

addr_to_client = {c.get("address"): c for c in clients if c.get("address")}
active_addr = active.get("address")
if not active_addr or active_addr not in addr_to_client:
    raise SystemExit(0)

active_client = addr_to_client.get(active_addr) or {}
grouped = active_client.get("grouped")
if isinstance(grouped, list) and grouped:
    members = [a for a in grouped if a in addr_to_client]
    if not members:
        members = [active_addr]
else:
    members = [active_addr]
group_key = ",".join(sorted(members))

cache = {}
try:
    with open(cache_file, "r", encoding="utf-8") as f:
        cache = json.load(f) or {}
except Exception:
    cache = {}

group_last = {}
pos_cache = {}
if isinstance(cache, dict) and ("group_last" in cache or "pos" in cache):
    group_last = cache.get("group_last") or {}
    pos_cache = cache.get("pos") or {}
elif isinstance(cache, dict):
    group_last = cache
    pos_cache = {}
cache = {"group_last": group_last, "pos": pos_cache}
group_last[group_key] = active_addr
try:
    with open(cache_file, "w", encoding="utf-8") as f:
        json.dump(cache, f)
except Exception:
    pass
PY
  if [[ "$internal" =~ ^[0-3]$ ]] && [[ "$client" =~ ^[0-3]$ ]] && { [[ "$internal" != "0" ]] || [[ "$client" != "0" ]]; }; then
    hyprctl dispatch fullscreenstate "$internal" "$client" set
  fi
  exit 0
fi

target="$(
  CACHE_FILE="$cache_file" FULLSCREEN="$is_fullscreen" python3 - "$direction" "$mode" <<'PY' || true
import json
import os
import subprocess
import sys

direction = sys.argv[1] if len(sys.argv) > 1 else "next"
mode = sys.argv[2] if len(sys.argv) > 2 else "workspace"
if mode not in ("workspace", "all"):
    mode = "workspace"
cache_file = os.environ.get("CACHE_FILE")
is_fullscreen = os.environ.get("FULLSCREEN") == "1"

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
aw = active.get("workspace") or {}
aw_name = str(aw.get("name") or "")
aw_id = str(aw.get("id") or "")
if aw_name and (aw_name.startswith("special:") or aw_id.startswith("-")):
    ws_name = aw_name or ws_name
    ws_id = aw_id or ws_id

def in_ws(client):
    w = client.get("workspace") or {}
    return str(w.get("name") or "") == ws_name or str(w.get("id") or "") == ws_id

def is_pinned(client):
    return bool(client.get("pinned"))

items = [c for c in clients if in_ws(c) and not is_pinned(c)]
if len(items) < 2:
    sys.exit(0)

addr_to_client = {c.get("address"): c for c in items if c.get("address")}
addr_set = set(addr_to_client)
if not addr_set:
    sys.exit(0)

def focus_id(addr):
    c = addr_to_client.get(addr) or {}
    try:
        return int(c.get("focusHistoryID") or -1)
    except Exception:
        return -1

cache = {}
if cache_file:
    try:
        with open(cache_file, "r", encoding="utf-8") as f:
            cache = json.load(f) or {}
    except Exception:
        cache = {}

group_last = {}
pos_cache = {}
if isinstance(cache, dict) and ("group_last" in cache or "pos" in cache):
    group_last = cache.get("group_last") or {}
    pos_cache = cache.get("pos") or {}
elif isinstance(cache, dict):
    group_last = cache
    pos_cache = {}

parent = {addr: addr for addr in addr_set}

def find(x):
    while parent.get(x) != x:
        parent[x] = parent.get(parent[x], parent[x])
        x = parent.get(x, x)
    return x

def union(a, b):
    ra = find(a)
    rb = find(b)
    if ra != rb:
        parent[rb] = ra

def pos(addr):
    if is_fullscreen:
        cached = pos_cache.get(addr)
        if isinstance(cached, list) and len(cached) >= 2:
            return (cached[0], cached[1])
    c = addr_to_client.get(addr) or {}
    at = c.get("at") or [0, 0]
    x = at[0] if len(at) > 0 else 0
    y = at[1] if len(at) > 1 else 0
    return (x, y)

group_order_candidates = {}
for addr, c in addr_to_client.items():
    grouped = c.get("grouped")
    if isinstance(grouped, list) and grouped:
        members = [a for a in grouped if a in addr_set]
        if members:
            key = ",".join(sorted(members))
            if key not in group_order_candidates or len(members) > len(group_order_candidates[key]):
                group_order_candidates[key] = members
        for other in grouped:
            if other in addr_set:
                union(addr, other)

groups = {}
addr_to_group = {}
for addr in addr_set:
    root = find(addr)
    groups.setdefault(root, []).append(addr)

for root, members in groups.items():
    members.sort()
    group_id = ",".join(members)
    groups[root] = members
    for addr in members:
        addr_to_group[addr] = group_id

group_entries = []
members_order_by_group = {}
active_addr = active.get("address")
if active_addr not in addr_set:
    active_addr = max(addr_set, key=focus_id, default=None)
if not active_addr:
    sys.exit(0)
active_group = addr_to_group.get(active_addr)
if active_group:
    group_last[active_group] = active_addr

def pick_rep(members, group_key):
    cached = group_last.get(group_key)
    if cached in members:
        return cached
    rep = max(members, key=focus_id)
    if focus_id(rep) >= 0:
        return rep
    return sorted(members)[0]

for group_id, members in groups.items():
    group_pos = min((pos(a) for a in members), default=(0, 0))
    real_id = ",".join(members)
    order = list(group_order_candidates.get(real_id, []))
    if not order:
        order = list(members)
    else:
        missing = [m for m in members if m not in set(order)]
        if missing:
            order.extend(sorted(missing))
    members_order_by_group[real_id] = order
    rep = pick_rep(members, real_id)
    group_entries.append((group_pos, real_id, rep))

group_entries.sort(key=lambda item: (item[0][0], item[0][1], item[1]))
group_ids = [gid for _, gid, _ in group_entries]
rep_by_group = {gid: rep for _, gid, rep in group_entries}
if len(group_ids) < 2:
    sys.exit(0)

if not active_group:
    sys.exit(0)

if mode == "all":
    addresses = []
    for gid in group_ids:
        addresses.extend(members_order_by_group.get(gid, []))
    if len(addresses) < 2:
        sys.exit(0)
    try:
        idx = addresses.index(active_addr)
    except ValueError:
        idx = 0
    if direction == "prev":
        idx = (idx - 1) % len(addresses)
    else:
        idx = (idx + 1) % len(addresses)
    target = addresses[idx]
else:
    if direction == "prev":
        idx = (group_ids.index(active_group) - 1) % len(group_ids)
    else:
        idx = (group_ids.index(active_group) + 1) % len(group_ids)
    target = rep_by_group[group_ids[idx]]

if cache_file:
    try:
        if not is_fullscreen:
            for addr in addr_set:
                x, y = pos(addr)
                pos_cache[addr] = [x, y]
        cache = {"group_last": group_last, "pos": pos_cache}
        with open(cache_file, "w", encoding="utf-8") as f:
            json.dump(cache, f)
    except Exception:
        pass

sys.stdout.write(target)
PY
)"

if [[ -n "$target" ]]; then
  hyprctl dispatch focuswindow "address:${target}"
fi

if [[ "$internal" =~ ^[0-3]$ ]] && [[ "$client" =~ ^[0-3]$ ]] && { [[ "$internal" != "0" ]] || [[ "$client" != "0" ]]; }; then
  hyprctl dispatch fullscreenstate "$internal" "$client" set
fi
