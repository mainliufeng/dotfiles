#!/usr/bin/env sh
set -eu

notif_id="${1:-${id:-}}"
if [ -z "$notif_id" ]; then
  exit 0
fi

log_file="$HOME/.local/share/mako/notifications.jsonl"
text=""

if [ -f "$log_file" ]; then
  text=$(python3 - "$notif_id" "$log_file" <<'PY' 2>/dev/null || true
import json
import sys

target = sys.argv[1]
path = sys.argv[2]

best = None
with open(path, "r", encoding="utf-8") as f:
    for line in f:
        line = line.strip()
        if not line:
            continue
        try:
            item = json.loads(line)
        except Exception:
            continue
        if str(item.get("id", "")) != target:
            continue
        ts = int(item.get("ts", 0))
        summary = item.get("summary") or ""
        body = item.get("body") or ""
        text = summary if not body else summary + "\n" + body
        if best is None or ts >= best[0]:
            best = (ts, text)

if best:
    print(best[1])
    sys.exit(0)

sys.exit(1)
PY
  )
fi

if [ -z "$text" ]; then
  raw=$(makoctl list 2>/dev/null || true)
  if [ -z "$raw" ]; then
    exit 0
  fi

  text=$(printf '%s' "$raw" | python3 -c 'import re,sys
if len(sys.argv) < 2:
    sys.exit(0)
target=sys.argv[1]
lines=sys.stdin.read().splitlines()
entries=[]
current=None
reading_body=False
for line in lines:
    m=re.match(r"^Notification ([0-9]+):\s*(.*)$", line)
    if m:
        if current:
            entries.append(current)
        current={"id": m.group(1), "summary": m.group(2), "body": []}
        reading_body=False
        continue
    if current is None:
        continue
    if line.startswith("  Body:"):
        body=line[len("  Body:"):].lstrip()
        if body:
            current["body"].append(body)
        reading_body=True
        continue
    if reading_body:
        if line.startswith("    "):
            current["body"].append(line[4:])
            continue
        reading_body=False
if current:
    entries.append(current)
text=""
for item in entries:
    if item.get("id") == target:
        summary=item.get("summary") or ""
        body="\n".join(item.get("body") or [])
        text=summary if not body else f"{summary}\n{body}"
        break
sys.stdout.write(text)
' "$notif_id")
fi

if [ -n "$text" ]; then
  printf '%s' "$text" | wl-copy
fi
