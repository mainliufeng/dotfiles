#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
script="$repo_root/codex/agents_md/waybar-codex.sh"
fragments_dir="$repo_root/codex/agents_md"

tmp_home=$(mktemp -d)
trap 'rm -rf "$tmp_home"' EXIT

export HOME="$tmp_home"
export FRAGMENTS_DIR="$fragments_dir"

mapfile -t fragments < <(find "$fragments_dir" -maxdepth 1 -type f -name '*.md' -printf '%f\n' \
  | sed 's/\.md$//' \
  | grep -v '^README$' \
  | sort)

if [ "${#fragments[@]}" -eq 0 ]; then
  echo "No fragments found for test" >&2
  exit 1
fi

output=$("$script" status)
printf '%s' "$output" | python - <<'PY'
import json
import os
import sys

fragments_dir = os.environ["FRAGMENTS_DIR"]
fragments = sorted(
    name[:-3]
    for name in os.listdir(fragments_dir)
    if name.endswith(".md") and name != "README.md"
)

data = json.loads(sys.stdin.read())
text = data.get("text", "")
tooltip = data.get("tooltip", "")

if "Codex" not in text:
    raise SystemExit("missing Codex label in text")

lines = [line.strip() for line in tooltip.splitlines() if line.strip()]

missing = []
for name in fragments:
    expected = f"[ ] {name}"
    alt = f"[x] {name}"
    if expected not in lines and alt not in lines:
        missing.append(name)

if missing:
    raise SystemExit(f"missing checkbox lines for: {', '.join(missing)}")
PY

mkdir -p "$HOME/.codex"

current="${fragments[0]}"
echo "$current" > "$HOME/.codex/agents_md.cursor"

"$script" toggle
if ! grep -qx "$current" "$HOME/.codex/agents_md.enabled"; then
  echo "toggle did not enable $current" >&2
  exit 1
fi

"$script" toggle
if [ -s "$HOME/.codex/agents_md.enabled" ]; then
  echo "toggle did not disable $current" >&2
  exit 1
fi

if [ "${#fragments[@]}" -gt 1 ]; then
  echo "${fragments[0]}" > "$HOME/.codex/agents_md.cursor"
  "$script" next
  if ! grep -qx "${fragments[1]}" "$HOME/.codex/agents_md.cursor"; then
    echo "next did not advance cursor" >&2
    exit 1
  fi

  "$script" prev
  if ! grep -qx "${fragments[0]}" "$HOME/.codex/agents_md.cursor"; then
    echo "prev did not move cursor back" >&2
    exit 1
  fi
fi

echo "ok"
