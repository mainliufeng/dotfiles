#!/usr/bin/env sh
set -eu

raw=$(makoctl history 2>/dev/null || true)
if [ -z "$raw" ]; then
  raw=$(makoctl list 2>/dev/null || true)
fi
if [ -z "$raw" ]; then
  exit 0
fi

menu=$(printf '%s' "$raw" | python3 -c 'import re,sys
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
out=[]
for item in entries:
    summary=(item.get("summary") or "").replace("\t"," ").replace("\n"," ")
    body=" ".join(item.get("body") or []).replace("\t"," ").replace("\n"," ")
    text=summary if not body else f"{summary} - {body}"
    out.append("{}\t{}".format(item["id"], text))
sys.stdout.write("\n".join(out))
')

if [ -z "$menu" ]; then
  exit 0
fi

selection=$(printf '%s\n' "$menu" | wofi --show dmenu --prompt 'Mako History' --insensitive)
if [ -z "$selection" ]; then
  exit 0
fi

text="${selection#*$'\t'}"
if [ -n "$text" ]; then
  printf '%s' "$text" | wl-copy
fi
