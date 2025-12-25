#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

fragments_dir="${CODE_AGENTS_FRAGMENTS_DIR:-$HOME/dotfiles/code_agents/agents_md}"
code_agents_cmd="${CODE_AGENTS_CMD:-code-agents-config}"

mapfile -t fragments < <(find "$fragments_dir" -maxdepth 1 -type f -name '*.md' -printf '%f\n' \
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

command="${1:-status}"
if [ "$command" = "menu" ]; then
  if ! command -v "$code_agents_cmd" >/dev/null 2>&1; then
    echo "code-agents-config not found in PATH" >&2
    exit 1
  fi
  "$code_agents_cmd"
  exit 0
fi

enabled_names=()
user_agents_file="$HOME/.codex/AGENTS.md"
if [ ! -f "$user_agents_file" ]; then
  user_agents_file="$HOME/.claude/CLAUDE.md"
fi

if [ -f "$user_agents_file" ]; then
  while IFS= read -r name; do
    if [ -n "$name" ]; then
      enabled_names+=("$name")
    fi
  done < <(python3 - "$user_agents_file" "$fragments_dir" "${fragments[@]}" <<'PY'
import sys
from pathlib import Path

agents_file = Path(sys.argv[1])
fragments_dir = Path(sys.argv[2])
all_names = sys.argv[3:]

try:
    agents_text = agents_file.read_text()
except FileNotFoundError:
    agents_text = ""

selected = []
for name in all_names:
    fragment_path = fragments_dir / f"{name}.md"
    try:
        fragment_text = fragment_path.read_text().rstrip()
    except FileNotFoundError:
        continue
    if fragment_text and fragment_text in agents_text:
        selected.append(name)

print("\n".join(selected))
PY
)
fi

declare -A enabled
for name in "${enabled_names[@]}"; do
  enabled["$name"]=1
done

enabled_count=0
tooltip_lines=()
for name in "${fragments[@]}"; do
  if [ -n "${enabled[$name]:-}" ]; then
    tooltip_lines+=("[x] $name")
    enabled_count=$((enabled_count + 1))
  else
    tooltip_lines+=("[ ] $name")
  fi
done

tooltip=$(printf '%s\n' "${tooltip_lines[@]}")
text="AGENT.md"
class="codex disabled"
if [ "$enabled_count" -gt 0 ]; then
  class="codex enabled"
fi

emit_json "$text" "$tooltip" "$class"
