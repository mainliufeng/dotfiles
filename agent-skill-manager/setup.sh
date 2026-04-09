#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
SKILL_SRC="$ROOT_DIR/skill"
TARGET="all"
DRY_RUN="0"

usage() {
  cat <<'EOF'
Usage: setup.sh [--target codex|claude-code|hermes|all] [--dry-run]

Installs the agent-skill-manager skill itself by symlinking it into runtime skill directories.
This does NOT install the rest of the catalog yet — that is the skill's job.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="$2"
      shift 2
      ;;
    --dry-run)
      DRY_RUN="1"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown arg '$1'" >&2
      usage >&2
      exit 1
      ;;
  esac
done

run() {
  if [[ "$DRY_RUN" == "1" ]]; then
    printf '[dry-run]'
    for arg in "$@"; do
      printf ' %q' "$arg"
    done
    printf '\n'
  else
    "$@"
  fi
}

ensure_parent() {
  local path="$1"
  run mkdir -p "$(dirname "$path")"
}

link_skill() {
  local target_name="$1"
  local dest="$2"
  ensure_parent "$dest"

  if [[ -L "$dest" ]]; then
    local current
    current="$(readlink "$dest")"
    if [[ "$current" == "$SKILL_SRC" ]]; then
      echo "[skip] $target_name already linked -> $SKILL_SRC"
      return 0
    fi
    run rm -f "$dest"
  elif [[ -e "$dest" ]]; then
    local backup="${dest}.bak.$(date +%Y%m%d%H%M%S)"
    run mv "$dest" "$backup"
    echo "Backed up existing $target_name skill to $backup"
  fi

  run ln -s "$SKILL_SRC" "$dest"
  echo "Linked $target_name -> $dest"
}

ensure_hermes_category() {
  local dir="$HOME/.hermes/skills/meta"
  local desc="$dir/DESCRIPTION.md"
  run mkdir -p "$dir"
  if [[ ! -f "$desc" ]]; then
    if [[ "$DRY_RUN" == "1" ]]; then
      echo "[dry-run] create $desc"
    else
      cat > "$desc" <<'EOF'
# meta

Meta-skills for managing the agent environment itself.
EOF
    fi
    echo "Created Hermes category description: $desc"
  fi
}

install_target() {
  local target_name="$1"
  case "$target_name" in
    codex)
      link_skill "codex" "$HOME/.codex/skills/agent-skill-manager"
      ;;
    claude-code)
      link_skill "claude-code" "$HOME/.claude/skills/agent-skill-manager"
      ;;
    hermes)
      ensure_hermes_category
      link_skill "hermes" "$HOME/.hermes/skills/meta/agent-skill-manager"
      ;;
    *)
      echo "Error: invalid target '$target_name'" >&2
      exit 1
      ;;
  esac
}

case "$TARGET" in
  all)
    targets=(codex claude-code hermes)
    ;;
  codex|claude-code|hermes)
    targets=("$TARGET")
    ;;
  *)
    echo "Error: invalid --target '$TARGET'" >&2
    exit 1
    ;;
esac

if [[ ! -d "$SKILL_SRC" ]]; then
  echo "Error: skill source missing: $SKILL_SRC" >&2
  exit 1
fi

for target_name in "${targets[@]}"; do
  install_target "$target_name"
done
