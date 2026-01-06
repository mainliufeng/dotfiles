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

if [[ "$direction" == "prev" ]]; then
  hyprctl dispatch cyclenext prev
else
  hyprctl dispatch cyclenext
fi

if [[ "$internal" =~ ^[0-3]$ ]] && [[ "$client" =~ ^[0-3]$ ]] && { [[ "$internal" != "0" ]] || [[ "$client" != "0" ]]; }; then
  hyprctl dispatch fullscreenstate "$internal" "$client" set
fi
