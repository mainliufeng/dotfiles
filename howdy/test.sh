#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  ./test.sh [-U <user>] [--xwayland] [--wayland]

Runs `howdy test` with the right environment on Wayland/XWayland and targets the
specified user's face models.

Examples:
  ./test.sh
  ./test.sh -U liufeng
  ./test.sh -U liufeng --wayland
  ./test.sh -U liufeng --xwayland
EOF
}

target_user="${SUDO_USER:-${USER:-}}"
force=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    -h|--help)
      usage
      exit 0
      ;;
    -U|--user)
      target_user="${2:-}"
      if [[ -z "${target_user}" ]]; then
        echo "[howdy][test] Error: -U/--user requires a value" >&2
        exit 2
      fi
      shift 2
      ;;
    --wayland|--xwayland)
      force="$1"
      shift
      ;;
    *)
      echo "[howdy][test] Error: unknown arg: $1" >&2
      usage
      exit 2
      ;;
  esac
done

if [[ -z "${target_user}" ]]; then
  echo "[howdy][test] Error: could not determine target user" >&2
  exit 1
fi

run_wayland() {
  if [[ -z "${WAYLAND_DISPLAY:-}" || -z "${XDG_RUNTIME_DIR:-}" ]]; then
    echo "[howdy][test] Error: WAYLAND_DISPLAY/XDG_RUNTIME_DIR not set" >&2
    exit 1
  fi
  sudo env \
    WAYLAND_DISPLAY="${WAYLAND_DISPLAY}" \
    XDG_RUNTIME_DIR="${XDG_RUNTIME_DIR}" \
    QT_QPA_PLATFORM=wayland \
    howdy test -U "${target_user}"
}

run_xwayland() {
  if [[ -z "${DISPLAY:-}" ]]; then
    echo "[howdy][test] Error: DISPLAY not set" >&2
    exit 1
  fi

  if command -v xhost >/dev/null 2>&1; then
    xhost +SI:localuser:root >/dev/null
    trap 'xhost -SI:localuser:root >/dev/null 2>&1 || true' EXIT
  else
    echo "[howdy][test] Warning: xhost not found; sudo GUI may fail to connect to X." >&2
  fi

  sudo env DISPLAY="${DISPLAY}" howdy test -U "${target_user}"
}

case "${force}" in
  --wayland) run_wayland ;;
  --xwayland) run_xwayland ;;
  "")
    if [[ -n "${WAYLAND_DISPLAY:-}" && -n "${XDG_RUNTIME_DIR:-}" ]]; then
      run_wayland
    else
      run_xwayland
    fi
    ;;
esac

