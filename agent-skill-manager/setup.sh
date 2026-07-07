#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="all"
DRY_RUN="0"

usage() {
  cat <<'EOF'
Usage: setup.sh [--target codex|hermes|all] [--dry-run]

Bootstraps the agent-skill-manager skill itself using the fixed registry sync script.
Use bin/skill-manager sync to install the full configured registry.
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

case "$TARGET" in
  codex|hermes|all) ;;
  *)
    echo "Error: invalid --target '$TARGET'" >&2
    usage >&2
    exit 1
    ;;
esac

cmd=("$ROOT_DIR/bin/skill-manager" sync --only agent-skill-manager --target "$TARGET")
if [[ "$DRY_RUN" == "1" ]]; then
  cmd+=(--dry-run)
fi

"${cmd[@]}"
