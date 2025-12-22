#!/usr/bin/env sh
set -eu

notif_id="${1:-${id:-}}"
if [ -z "$notif_id" ]; then
  exit 0
fi

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

if [ -n "$text" ]; then
  printf '%s' "$text" | wl-copy
fi
