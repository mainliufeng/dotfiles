#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
skills_dir="$script_dir/skills"
codex_home="${CODEX_HOME:-$HOME/.codex}"
installer="$codex_home/skills/.system/skill-installer/scripts/install-skill-from-github.py"

if [ ! -f "$installer" ]; then
  echo "Skill installer not found: $installer" >&2
  exit 1
fi

mkdir -p "$skills_dir"

rm -rf "$skills_dir/webapp-testing"
python3 "$installer" \
  --repo anthropics/skills \
  --path skills/webapp-testing \
  --dest "$skills_dir"

rm -rf "$skills_dir/frontend-design"
python3 "$installer" \
  --repo anthropics/skills \
  --path skills/frontend-design \
  --dest "$skills_dir"

rm -rf "$skills_dir/tapestry"
python3 "$installer" \
  --repo michalparkola/tapestry-skills-for-claude-code \
  --path tapestry \
  --dest "$skills_dir"

rm -rf "$skills_dir/content-research-writer"
python3 "$installer" \
  --url https://github.com/ComposioHQ/awesome-claude-skills/tree/master/content-research-writer \
  --dest "$skills_dir"
