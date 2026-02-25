#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET="all"
MANIFEST="$SCRIPT_DIR/config/manifest.json"
SKIP_SKILLS="0"
SKIP_MD="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target)
      TARGET="$2"
      shift 2
      ;;
    --manifest)
      MANIFEST="$2"
      shift 2
      ;;
    --skip-skills)
      SKIP_SKILLS="1"
      shift
      ;;
    --skip-md)
      SKIP_MD="1"
      shift
      ;;
    *)
      echo "Error: unknown arg '$1'" >&2
      exit 1
      ;;
  esac
done

if [[ "$SKIP_SKILLS" != "1" ]]; then
  "$SCRIPT_DIR/scripts/install-skills.sh" --target "$TARGET" --manifest "$MANIFEST"
fi

if [[ "$SKIP_MD" != "1" ]]; then
  "$SCRIPT_DIR/scripts/build-agent-md.sh" --target "$TARGET" --manifest "$MANIFEST"
fi
