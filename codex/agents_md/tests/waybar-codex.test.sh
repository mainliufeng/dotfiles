#!/usr/bin/env bash
set -euo pipefail

repo_root=$(git rev-parse --show-toplevel)
script="$repo_root/codex/agents_md/waybar-codex.sh"
fragments_dir="$repo_root/codex/agents_md"

tmp_home=$(mktemp -d)
trap 'rm -rf "$tmp_home"' EXIT

export HOME="$tmp_home"
export FRAGMENTS_DIR="$fragments_dir"

stub_dir="$tmp_home/bin"
mkdir -p "$stub_dir"
cat <<'SH' > "$stub_dir/agents-md"
#!/usr/bin/env bash
set -euo pipefail

codex_dir="${CODEX_DIR:-$HOME/.codex}"
enabled_file="$codex_dir/agents_md.enabled"

mkdir -p "$codex_dir"

cmd="${1:-}"
shift || true

case "$cmd" in
  enable)
    for name in "$@"; do
      if ! grep -qx "$name" "$enabled_file" 2>/dev/null; then
        printf '%s\n' "$name" >> "$enabled_file"
      fi
    done
    ;;
  disable)
    if [ -f "$enabled_file" ]; then
      tmp="$(mktemp)"
      cp "$enabled_file" "$tmp"
      for name in "$@"; do
        grep -vx "$name" "$tmp" > "${tmp}.next" || true
        mv "${tmp}.next" "$tmp"
      done
      mv "$tmp" "$enabled_file"
    fi
    ;;
  *)
    echo "unsupported command: $cmd" >&2
    exit 1
    ;;
esac
SH
chmod +x "$stub_dir/agents-md"
export PATH="$stub_dir:$PATH"

mapfile -t fragments < <(find "$fragments_dir" -maxdepth 1 -type f -name '*.md' -printf '%f\n' \
  | sed 's/\.md$//' \
  | grep -v '^README$' \
  | sort)

if [ "${#fragments[@]}" -eq 0 ]; then
  echo "No fragments found for test" >&2
  exit 1
fi

output=$("$script" status)
OUTPUT="$output" python - <<'PY'
import json
import os

fragments_dir = os.environ["FRAGMENTS_DIR"]
fragments = sorted(
    name[:-3]
    for name in os.listdir(fragments_dir)
    if name.endswith(".md") and name != "README.md"
)

data = json.loads(os.environ["OUTPUT"])
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

output=$("$script" toggle)
if [ -n "$output" ]; then
  echo "toggle should be silent" >&2
  exit 1
fi
if ! grep -qx "$current" "$HOME/.codex/agents_md.enabled"; then
  echo "toggle did not enable $current" >&2
  exit 1
fi

output=$("$script" toggle)
if [ -n "$output" ]; then
  echo "toggle should be silent" >&2
  exit 1
fi
if [ -s "$HOME/.codex/agents_md.enabled" ]; then
  echo "toggle did not disable $current" >&2
  exit 1
fi

if [ "${#fragments[@]}" -gt 1 ]; then
  echo "${fragments[0]}" > "$HOME/.codex/agents_md.cursor"
  output=$("$script" next)
  if [ -n "$output" ]; then
    echo "next should be silent" >&2
    exit 1
  fi
  if ! grep -qx "${fragments[1]}" "$HOME/.codex/agents_md.cursor"; then
    echo "next did not advance cursor" >&2
    exit 1
  fi

  output=$("$script" prev)
  if [ -n "$output" ]; then
    echo "prev should be silent" >&2
    exit 1
  fi
  if ! grep -qx "${fragments[0]}" "$HOME/.codex/agents_md.cursor"; then
    echo "prev did not move cursor back" >&2
    exit 1
  fi
fi

echo "ok"
