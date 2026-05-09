#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ACTION="link"
PLATFORM=""
COMMON_ONLY=0
PLATFORM_ONLY=0
DRY_RUN=0
KEEP_GOING=0

usage() {
  cat <<'EOF'
Usage: ./link.sh [options]

Options:
  --common-only          Link only common modules
  --platform-only        Link only platform modules
  --platform linux|macos Override platform detection
  --dry-run              Print actions without running them
  --keep-going           Continue after a module fails
  -h, --help             Show this help
EOF
}

detect_platform() {
  case "$(uname -s)" in
    Darwin) echo "macos" ;;
    Linux) echo "linux" ;;
    *)
      echo "unsupported"
      ;;
  esac
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --common-only)
      COMMON_ONLY=1
      shift
      ;;
    --platform-only)
      PLATFORM_ONLY=1
      shift
      ;;
    --platform)
      PLATFORM="${2:-}"
      shift 2
      ;;
    --dry-run)
      DRY_RUN=1
      shift
      ;;
    --keep-going)
      KEEP_GOING=1
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ "$COMMON_ONLY" == "1" && "$PLATFORM_ONLY" == "1" ]]; then
  echo "--common-only and --platform-only cannot be used together" >&2
  exit 1
fi

if [[ -z "$PLATFORM" ]]; then
  PLATFORM="$(detect_platform)"
fi

case "$PLATFORM" in
  linux|macos) ;;
  *)
    echo "Unsupported platform: $PLATFORM" >&2
    exit 1
    ;;
esac

run_list() {
  local list_path="$1"
  DOTFILES_DRY_RUN="$DRY_RUN" DOTFILES_KEEP_GOING="$KEEP_GOING" \
    "$ROOT_DIR/scripts/dotfiles-run-modules" "$ACTION" "$list_path"
}

if [[ "$PLATFORM_ONLY" != "1" ]]; then
  run_list "$ROOT_DIR/modules/common.txt"
fi

if [[ "$COMMON_ONLY" != "1" ]]; then
  run_list "$ROOT_DIR/modules/$PLATFORM.txt"
fi
