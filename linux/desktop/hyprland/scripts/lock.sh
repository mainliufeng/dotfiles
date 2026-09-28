#!/usr/bin/env bash
set -euo pipefail

# Lock the session.
#
# cornice owns the lock while it is running: it takes the Wayland session lock
# and authenticates through the same PAM stack as hyprlock (/etc/pam.d/hyprlock,
# Howdy included). hyprlock stays as the fallback, so the session can always be
# locked even when the shell is not running or refuses to lock.
sock="${XDG_RUNTIME_DIR:-/tmp}/cornice-${USER:-user}.sock"

if [[ -S $sock ]] && command -v cornice >/dev/null 2>&1; then
  result=$(timeout 5 cornice ipc lock lock 2>/dev/null || true)
  case "$result" in
    ok|already-locked) exit 0 ;;
  esac
fi

if pgrep -x hyprlock >/dev/null 2>&1; then
  exit 0
fi

exec hyprlock
