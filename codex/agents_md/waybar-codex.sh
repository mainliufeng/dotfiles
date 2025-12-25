#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

codex_dir="${CODEX_DIR:-${CODEX_HOME:-$HOME/.codex}}"
enabled_file="$codex_dir/agents_md.enabled"
cursor_file="$codex_dir/agents_md.cursor"
scroll_state_file="$codex_dir/agents_md.scroll_state"
agents_md_cmd="${AGENTS_MD_CMD:-agents-md}"
zenity_cmd="${ZENITY_CMD:-zenity}"

mapfile -t fragments < <(find "$script_dir" -maxdepth 1 -type f -name '*.md' -printf '%f\n' \
  | sed 's/\.md$//' \
  | grep -v '^README$' \
  | sort)

emit_json() {
  TEXT="$1" TOOLTIP="$2" CLASS="$3" python - <<'PY'
import json
import os

text = os.environ["TEXT"]
tooltip = os.environ["TOOLTIP"]
klass = os.environ["CLASS"]
print(json.dumps({"text": text, "tooltip": tooltip, "class": klass}))
PY
}

if [ "${#fragments[@]}" -eq 0 ]; then
  emit_json "Codex [no fragments]" "No fragments found" "codex empty"
  exit 0
fi

declare -A enabled
if [ -f "$enabled_file" ]; then
  while IFS= read -r line; do
    if [ -n "$line" ]; then
      enabled["$line"]=1
    fi
  done < "$enabled_file"
fi

current=""
if [ -f "$cursor_file" ]; then
  read -r current < "$cursor_file" || true
fi

found=0
for name in "${fragments[@]}"; do
  if [ "$name" = "$current" ]; then
    found=1
    break
  fi
done

if [ "$found" -eq 0 ]; then
  current="${fragments[0]}"
fi

command="${1:-status}"

case "$command" in
  next|prev)
    if [ "${#fragments[@]}" -le 1 ]; then
      exit 0
    fi

    scroll_step=5
    last_dir=""
    last_count=0
    if [ -f "$scroll_state_file" ]; then
      read -r last_dir last_count < "$scroll_state_file" || true
    fi
    if [ "$last_dir" = "$command" ]; then
      count=$((last_count + 1))
    else
      count=1
    fi
    if [ "$count" -lt "$scroll_step" ]; then
      mkdir -p "$codex_dir"
      printf '%s %s\n' "$command" "$count" > "$scroll_state_file"
      exit 0
    fi

    rm -f "$scroll_state_file"
    index=0
    for i in "${!fragments[@]}"; do
      if [ "${fragments[$i]}" = "$current" ]; then
        index="$i"
        break
      fi
    done
    if [ "$command" = "next" ]; then
      index=$(( (index + 1) % ${#fragments[@]} ))
    else
      index=$(( (index - 1 + ${#fragments[@]}) % ${#fragments[@]} ))
    fi
    current="${fragments[$index]}"
    mkdir -p "$codex_dir"
    printf '%s\n' "$current" > "$cursor_file"
    exit 0
    ;;
  toggle)
    mkdir -p "$codex_dir"
    if ! command -v "$agents_md_cmd" >/dev/null 2>&1; then
      echo "agents-md not found in PATH" >&2
      exit 1
    fi
    if [ -n "${enabled[$current]:-}" ]; then
      "$agents_md_cmd" disable "$current" >/dev/null
    else
      "$agents_md_cmd" enable "$current" >/dev/null
    fi
    exit 0
    ;;
  menu)
    if ! command -v "$zenity_cmd" >/dev/null 2>&1; then
      echo "zenity not found in PATH" >&2
      exit 1
    fi
    if ! command -v "$agents_md_cmd" >/dev/null 2>&1; then
      echo "agents-md not found in PATH" >&2
      exit 1
    fi
    zenity_args=(--list --checklist --title "AGENT.md" --column "On" --column "Fragment" --separator=$'\n')
    for name in "${fragments[@]}"; do
      if [ -n "${enabled[$name]:-}" ]; then
        zenity_args+=("TRUE" "$name")
      else
        zenity_args+=("FALSE" "$name")
      fi
    done
    selection=$("$zenity_cmd" "${zenity_args[@]}" 2>/dev/null)
    zenity_status=$?
    if [ "$zenity_status" -ne 0 ]; then
      exit 0
    fi
    if [ -z "$selection" ]; then
      selection_list=()
    else
      mapfile -t selection_list <<<"$selection"
    fi
    declare -A selected
    for name in "${selection_list[@]}"; do
      if [ -n "$name" ]; then
        selected["$name"]=1
      fi
    done
    to_enable=()
    to_disable=()
    for name in "${fragments[@]}"; do
      if [ -n "${selected[$name]:-}" ]; then
        if [ -z "${enabled[$name]:-}" ]; then
          to_enable+=("$name")
        fi
      else
        if [ -n "${enabled[$name]:-}" ]; then
          to_disable+=("$name")
        fi
      fi
    done
    if [ "${#selection_list[@]}" -gt 0 ]; then
      mkdir -p "$codex_dir"
      printf '%s\n' "${selection_list[0]}" > "$cursor_file"
    fi
    mkdir -p "$codex_dir"
    if [ "${#to_enable[@]}" -gt 0 ]; then
      "$agents_md_cmd" enable "${to_enable[@]}" >/dev/null
    fi
    if [ "${#to_disable[@]}" -gt 0 ]; then
      "$agents_md_cmd" disable "${to_disable[@]}" >/dev/null
    fi
    exit 0
    ;;
  status)
    ;;
  *)
    emit_json "Codex [unknown]" "Unknown command: $command" "codex error"
    exit 0
    ;;
esac

unset enabled
declare -A enabled
if [ -f "$enabled_file" ]; then
  while IFS= read -r line; do
    if [ -n "$line" ]; then
      enabled["$line"]=1
    fi
  done < "$enabled_file"
fi

if [ -f "$cursor_file" ]; then
  read -r current < "$cursor_file" || true
fi

current_enabled=0
if [ -n "${enabled[$current]:-}" ]; then
  current_enabled=1
fi

checkbox="[ ]"
class="codex disabled"
if [ "$current_enabled" -eq 1 ]; then
  checkbox="[x]"
  class="codex enabled"
fi

tooltip_lines=()
for name in "${fragments[@]}"; do
  if [ -n "${enabled[$name]:-}" ]; then
    tooltip_lines+=("[x] $name")
  else
    tooltip_lines+=("[ ] $name")
  fi
done

tooltip=$(printf '%s\n' "${tooltip_lines[@]}")
text="AGENT.md"

emit_json "$text" "$tooltip" "$class"
