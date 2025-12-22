#!/usr/bin/env sh
set -eu

log_file="$HOME/.local/share/mako/notifications.jsonl"

menu=$(python3 - <<'PY'
import json
import os
import re
import subprocess

base_dir = os.path.expanduser("~/.local/share/mako")
log_path = os.path.join(base_dir, "notifications.jsonl")
session_path = os.path.join(base_dir, "notify-log.session")

def parse_mako(text):
    lines = text.splitlines()
    entries = []
    current = None
    reading_body = False
    for line in lines:
        m = re.match(r"^Notification ([0-9]+):\s*(.*)$", line)
        if m:
            if current:
                entries.append(current)
            current = {"id": m.group(1), "summary": m.group(2), "body": []}
            reading_body = False
            continue
        if current is None:
            continue
        if line.startswith("  Body:"):
            body = line[len("  Body:"):].lstrip()
            if body:
                current["body"].append(body)
            reading_body = True
            continue
        if reading_body:
            if line.startswith("    "):
                current["body"].append(line[4:])
                continue
            reading_body = False
    if current:
        entries.append(current)
    return entries

try:
    raw_list = subprocess.check_output(["makoctl", "list"], text=True, stderr=subprocess.DEVNULL)
except Exception:
    raw_list = ""

session_start = 0
if os.path.exists(session_path):
    try:
        with open(session_path, "r", encoding="utf-8") as f:
            session_start = int(f.read().strip() or "0")
    except Exception:
        session_start = 0

if not os.path.exists(log_path) and not raw_list:
    raise SystemExit(0)

log_entries = {}
if os.path.exists(log_path):
    with open(log_path, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            try:
                item = json.loads(line)
            except Exception:
                continue
            nid = str(item.get("id", ""))
            if not nid:
                continue
            ts = int(item.get("ts", 0))
            if session_start and ts < session_start:
                continue
            log_entries[nid] = {
                "id": nid,
                "ts": ts,
                "summary": item.get("summary") or "",
                "body": item.get("body") or "",
            }

entries = []
seen = set()
now_ts = int(os.path.getmtime(session_path)) if os.path.exists(session_path) else 0
have_log = bool(log_entries)
for item in parse_mako(raw_list):
    nid = item["id"]
    if nid in seen:
        continue
    if have_log and nid not in log_entries:
        continue
    seen.add(nid)
    summary = item.get("summary") or ""
    body = " ".join(item.get("body") or [])
    if nid in log_entries:
        summary = log_entries[nid].get("summary") or summary
        body = log_entries[nid].get("body") or body
        ts = log_entries[nid].get("ts", 0)
    else:
        ts = now_ts
    entries.append({"id": nid, "summary": summary, "body": body, "ts": ts})

out = []
for item in sorted(entries, key=lambda x: (int(x["ts"]), int(x["id"])), reverse=True):
    summary = (item.get("summary") or "").replace("\t", " ").replace("\n", " ")
    body = (item.get("body") or "").replace("\t", " ").replace("\n", " ")
    text = summary if not body else "{} - {}".format(summary, body)
    out.append("{}\t{}".format(item["id"], text))

print("\n".join(out))
PY
)

if [ -z "$menu" ]; then
  exit 0
fi

selection=$(printf '%s\n' "$menu" | wofi --show dmenu --prompt 'Mako History' --insensitive --sort-order=default)
if [ -z "$selection" ]; then
  exit 0
fi

text="${selection#*$'\t'}"
if [ -n "$text" ]; then
  printf '%s' "$text" | wl-copy
fi
