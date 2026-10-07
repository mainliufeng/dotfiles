#!/usr/bin/env bash
set -euo pipefail

lua_string() {
  python3 - "$1" <<'LUA'
import sys
value = sys.argv[1]
marks = ''
while ']' + marks + ']' in value:
    marks += '='
print('[' + marks + '[\n' + value + ']' + marks + ']')
LUA
}

if [[ $# -lt 1 ]]; then
  exit 0
fi

msg=("$@")

active_ws_json="$(hyprctl -j activeworkspace 2>/dev/null || true)"
active_win_json="$(hyprctl -j activewindow 2>/dev/null || true)"

active_ws_name=""
active_ws_id=""
if [[ -n "$active_ws_json" ]]; then
  IFS=$'\t' read -r active_ws_name active_ws_id < <(
    python3 - <<'PY' <<<"$active_ws_json" || true
import json
import sys
try:
    data = json.load(sys.stdin)
except Exception:
    raise SystemExit(0)
name = data.get("name") or ""
ws_id = data.get("id")
print(f"{name}\t{ws_id if ws_id is not None else ''}")
PY
  ) || true
fi

active_win_ws_name=""
active_win_ws_id=""
if [[ -n "$active_win_json" ]]; then
  IFS=$'\t' read -r active_win_ws_name active_win_ws_id < <(
    python3 - <<'PY' <<<"$active_win_json" || true
import json
import sys
try:
    data = json.load(sys.stdin)
except Exception:
    raise SystemExit(0)
ws = data.get("workspace") or {}
name = ws.get("name") or ""
ws_id = ws.get("id")
print(f"{name}\t{ws_id if ws_id is not None else ''}")
PY
  ) || true
fi

if [[ -n "$active_win_ws_name" ]]; then
  if [[ "$active_win_ws_name" == special:* || ("$active_win_ws_id" =~ ^-?[0-9]+$ && "$active_win_ws_id" -lt 0) ]]; then
    if [[ -n "$active_ws_name" && "$active_win_ws_name" != "$active_ws_name" ]]; then
      hyprctl dispatch "hl.dsp.focus({workspace=$(lua_string "$active_win_ws_name")})" || true
      hyprctl dispatch "hl.dsp.layout($(lua_string "${msg[*]}"))" || true
      hyprctl dispatch "hl.dsp.focus({workspace=$(lua_string "$active_ws_name")})" || true
      exit 0
    fi
  fi
fi

hyprctl dispatch "hl.dsp.layout($(lua_string "${msg[*]}"))" || true
