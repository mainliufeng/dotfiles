#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

codex_dir="${CODEX_DIR:-${CODEX_HOME:-$HOME/.codex}}"
enabled_file="$codex_dir/agents_md.enabled"
cursor_file="$codex_dir/agents_md.cursor"
agents_md_cmd="${AGENTS_MD_CMD:-agents-md}"

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
    if [ "${#fragments[@]}" -gt 1 ]; then
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
    fi
    mkdir -p "$codex_dir"
    printf '%s\n' "$current" > "$cursor_file"
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
text="Codex $checkbox $current"

emit_json "$text" "$tooltip" "$class"
