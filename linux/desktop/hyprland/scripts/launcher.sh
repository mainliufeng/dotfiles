#!/usr/bin/env bash
set -euo pipefail

prompt_pick() {
  wofi --show dmenu --prompt "$1" --insensitive
}

prompt_pick_launcher() {
  wofi --show dmenu --prompt "$1" --insensitive \
    --pre-display-cmd "~/.config/hypr/scripts/launcher-pretty.sh \"%s\""
}

hypr_instance() {
  # Use existing signature if present; otherwise pick the instance matching WAYLAND_DISPLAY.
  if [[ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]]; then
    printf '%s\n' "$HYPRLAND_INSTANCE_SIGNATURE"
    return 0
  fi

  hyprctl -j instances 2>/dev/null | python -c '
import json,os,sys
try:
  items=json.load(sys.stdin)
except Exception:
  items=[]
if not items:
  sys.exit(0)
want=os.environ.get("WAYLAND_DISPLAY")
if want:
  for it in items:
    if it.get("wl_socket")==want and it.get("instance"):
      print(it["instance"])
      sys.exit(0)
print(items[0].get("instance",""))
'
}

hypr() {
  local inst
  inst="$(hypr_instance || true)"
  if [[ -n "$inst" ]]; then
    hyprctl --instance "$inst" "$@"
  else
    hyprctl "$@"
  fi
}

log() {
  local cache_dir log_file
  cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/hypr-launcher"
  log_file="${cache_dir}/launcher.log"
  mkdir -p "$cache_dir"
  printf '[%s] %s\n' "$(date -Is)" "$*" >>"$log_file"
}

workspace_history_file() {
  printf '%s\n' "${XDG_CACHE_HOME:-$HOME/.cache}/hypr-launcher/workspaces.txt"
}

remember_workspace() {
  local ws="$1"
  # Persist named workspaces so they remain searchable even when empty.
  if [[ "$ws" =~ ^[0-9]+$ ]]; then
    return 0
  fi
  if [[ "$ws" == special:* ]]; then
    return 0
  fi

  local file
  file="$(workspace_history_file)"
  mkdir -p "$(dirname "$file")"

  {
    printf '%s\n' "$ws"
    [[ -f "$file" ]] && cat "$file"
  } | awk 'NF && !seen[$0]++' | head -n 200 >"${file}.tmp"
  mv -f "${file}.tmp" "$file"
}

notify() {
  local icon="${1:-1}"
  local time_ms="${2:-2500}"
  local color="${3:-0}"
  shift 3 || true
  hypr notify "$icon" "$time_ms" "$color" "$*" >/dev/null 2>&1 || true
}

find_desktop_file() {
  local desktop_id="$1"
  local -a dirs=(
    "$HOME/.local/share/applications"
    "/usr/local/share/applications"
    "/usr/share/applications"
    "$HOME/.local/share/flatpak/exports/share/applications"
    "/var/lib/flatpak/exports/share/applications"
  )

  local dir
  for dir in "${dirs[@]}"; do
    [[ -d "$dir" ]] || continue
    if [[ -f "$dir/$desktop_id" ]]; then
      printf '%s\n' "$dir/$desktop_id"
      return 0
    fi
  done
  return 1
}

launch_via_exec_fallback() {
  local desktop_id="$1"
  local desktop_file exec_line

  desktop_file="$(find_desktop_file "$desktop_id" || true)"
  [[ -n "$desktop_file" ]] || return 1

  exec_line="$(
    awk '
      BEGIN{in=0}
      /^\[Desktop Entry\]/{in=1; next}
      in && /^\[/{exit}
      in && /^Exec=/{sub(/^Exec=/,""); print; exit}
    ' "$desktop_file"
  )"
  [[ -n "$exec_line" ]] || return 1

  # Strip desktop placeholders (we don't pass files/urls from the launcher).
  exec_line="${exec_line//%%/%}"
  exec_line="${exec_line//%u/}"
  exec_line="${exec_line//%U/}"
  exec_line="${exec_line//%f/}"
  exec_line="${exec_line//%F/}"
  exec_line="${exec_line//%i/}"
  exec_line="${exec_line//%c/}"
  exec_line="${exec_line//%k/}"

  # Execute detached; keep it simple and robust.
  nohup sh -lc "$exec_line" >/dev/null 2>&1 &
  disown || true
  return 0
}

collect_desktop_entries() {
  local cache_dir cache_file cache_ttl now mtime
  cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/hypr-launcher"
  cache_file="${cache_dir}/apps.tsv"
  cache_ttl="${HYPR_LAUNCHER_APPS_TTL:-43200}" # seconds, default 12h

  mkdir -p "$cache_dir"

  if [[ -f "$cache_file" ]]; then
    now="$(date +%s)"
    mtime="$(stat -c %Y "$cache_file" 2>/dev/null || echo 0)"
    if (( now - mtime < cache_ttl )) && [[ -s "$cache_file" ]]; then
      cat "$cache_file"
      return 0
    fi
  fi

  python - <<'PY' >"${cache_file}.tmp"
from __future__ import annotations

import os
from pathlib import Path

dirs = [
    Path(os.path.expanduser("~/.local/share/applications")),
    Path("/usr/local/share/applications"),
    Path("/usr/share/applications"),
    Path(os.path.expanduser("~/.local/share/flatpak/exports/share/applications")),
    Path("/var/lib/flatpak/exports/share/applications"),
]

seen: dict[str, str] = {}

def parse_desktop_name(path: Path) -> str | None:
    name_base: str | None = None
    name_en: str | None = None
    name_any: str | None = None
    hidden = False
    nodisplay = False
    try:
        with path.open("r", encoding="utf-8", errors="replace") as f:
            for i, line in enumerate(f):
                if i > 250:
                    break

                if line.startswith("Name=") and name_base is None:
                    name_base = line[len("Name=") :].strip()
                elif line.startswith("Name[en]") or line.startswith("Name[en_"):
                    if name_en is None:
                        name_en = line.split("=", 1)[-1].strip()
                elif line.startswith("Name[") and name_any is None:
                    # Fallback for entries that only provide localized names.
                    name_any = line.split("=", 1)[-1].strip()
                elif line.startswith("Hidden=true"):
                    hidden = True
                elif line.startswith("NoDisplay=true"):
                    nodisplay = True
    except OSError:
        return None

    name = name_base or name_en or name_any
    if not name:
        return None
    if hidden or nodisplay:
        return None
    return name

for d in dirs:
    if not d.is_dir():
        continue
    try:
        for entry in d.iterdir():
            if entry.suffix != ".desktop":
                continue
            desktop_id = entry.name
            if desktop_id in seen:
                continue
            name = parse_desktop_name(entry)
            if not name:
                continue
            seen[desktop_id] = name
    except OSError:
        continue

for desktop_id, name in sorted(seen.items(), key=lambda kv: kv[1].casefold()):
    print(f"APP\t{desktop_id}\t{name}")
PY

  mv -f "${cache_file}.tmp" "$cache_file"
  cat "$cache_file"
}

collect_workspaces() {
  local ws_json
  ws_json="$(hypr -j workspaces 2>/dev/null || echo '[]')"
  {
    printf '%s' "$ws_json" | python -c '
import json,sys
try:
  items=json.load(sys.stdin)
except Exception:
  items=[]
def key(w):
  # sort numeric names first
  name=w.get("name","")
  try:
    return (0,int(name))
  except Exception:
    return (1,name)
for w in sorted(items, key=key):
  name=w.get("name","")
  if not name:
    continue
  # Hide special workspace from the list (it’s an overlay, not a normal ws).
  if name.startswith("special:"):
    continue
  print(f"WS\t{name}\t{name}")
'
    local history
    history="$(workspace_history_file)"
    if [[ -f "$history" ]]; then
      awk 'NF {print "WS\t" $0 "\t" $0}' "$history"
    fi
  } | awk -F'\t' '$1=="WS" { if (!seen[$2]++) print }'
}

collect_commands() {
  cat <<'EOF'
CMD	reload	  Reload config
CMD	wallpaper	🖼  Random wallpaper
CMD	lock	󰍁  Lock
CMD	exit	⏻  Exit Hyprland
CMD	togglespecial	  Toggle special workspace
CMD	pin	🪟  Pin/Unpin (float only)
WS_CREATE	-	󰌒  Create/Go…
EOF
}

format_lines() {
  # input: TYPE \t ID \t LABEL
  while IFS=$'\t' read -r type id label; do
    case "$type" in
      # Keep machine-readable TSV; wofi --pre-display-cmd renders a concise display.
      APP) printf 'APP\t%s\t%s\n' "$id" "$label" ;;
      WS) printf 'WS\t%s\t%s\n' "$id" "$label" ;;
      CMD) printf 'CMD\t%s\t%s\n' "$id" "$label" ;;
      WS_CREATE) printf 'WS_CREATE\t-\t%s\n' "$label" ;;
    esac
  done
}

main() {
  local selection type data label
  selection="$(
    {
      collect_commands
      collect_workspaces
      collect_desktop_entries
    } | format_lines | prompt_pick_launcher 'Launcher'
  )"

  log "raw_selection=$(printf '%q' "${selection}")"
  [[ -z "${selection}" ]] && exit 0

  IFS=$'\t' read -r type data label <<<"$selection"
  log "selection.type=${type} selection.data=$(printf '%q' "${data}") selection.label=$(printf '%q' "${label}")"

  if [[ "$type" == "APP" ]]; then
    local id
    id="$data"
    log "app: id=$id base=${id%.desktop}"
    # gtk-launch uses desktop ID (usually without ".desktop"). If that fails (DBus / desktop activation),
    # fall back to Exec= from the desktop file.
    if gtk-launch "${id%.desktop}" >/dev/null 2>&1; then
      log "app: gtk-launch base ok"
      exit 0
    fi
    log "app: gtk-launch base failed ($?)"
    if gtk-launch "$id" >/dev/null 2>&1; then
      log "app: gtk-launch id ok"
      exit 0
    fi
    log "app: gtk-launch id failed ($?)"
    if launch_via_exec_fallback "$id"; then
      log "app: exec fallback ok"
      notify 1 2000 0 "Launched: ${id%.desktop}"
      exit 0
    fi
    log "app: exec fallback failed"
    notify 3 6000 0 "Failed to launch: ${id%.desktop}"
    exit 0
  fi

  if [[ "$type" == "WS_CREATE" ]]; then
    local name
    name="$(prompt_pick 'Workspace name')"
    [[ -z "${name}" ]] && exit 0
    # Allow entering "name:xxx" explicitly; otherwise treat as a named workspace.
    if [[ "$name" == name:* ]]; then
      hypr dispatch workspace "$name"
      remember_workspace "${name#name:}"
    elif [[ "$name" =~ ^[0-9]+$ ]]; then
      hypr dispatch workspace "$name"
    else
      hypr dispatch workspace "name:${name}"
      remember_workspace "$name"
    fi
    exit 0
  fi

  if [[ "$type" == "WS" ]]; then
    [[ -n "$data" ]] || exit 0
    hypr dispatch workspace "$data"
    remember_workspace "$data"
    exit 0
  fi

  [[ "$type" == "CMD" ]] || exit 0

  case "$data" in
    reload) hypr reload ;;
    wallpaper) "${HOME}/dotfiles/swww/scripts/wallpaper-random.sh" ;;
    lock) ~/.config/hypr/scripts/lock.sh ;;
    exit) hypr dispatch exit ;;
    togglespecial) hypr dispatch togglespecialworkspace ;;
    pin) hypr dispatch pin ;;
    *) exit 0 ;;
  esac
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  main "$@"
fi
