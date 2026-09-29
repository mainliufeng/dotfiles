#!/usr/bin/env bash
set -euo pipefail

# Lock the session.
#
# cornice owns the lock while it is running: it takes the Wayland session lock
# and authenticates through the same PAM stack as hyprlock (/etc/pam.d/hyprlock,
# Howdy included). hyprlock stays as the fallback, so the session can always be
# locked even when the shell is not running or refuses to lock.
# The Hyprland session PATH does not necessarily contain ~/.local/bin (this is
# why the compositor config defines $cornice with the absolute path), so look the
# CLI up by path instead of trusting `command -v`: a failed lookup here silently
# skipped cornice and fell back to hyprlock.
cornice_bin="${CORNICE_BIN:-$HOME/.local/bin/cornice}"
sock="${XDG_RUNTIME_DIR:-/tmp}/cornice-${USER:-user}.sock"

if [[ -S $sock && -x $cornice_bin ]]; then
  # Two attempts: the shell may be busy for a moment (restart, plugin reload) and
  # a single timeout used to fall through to hyprlock — which looked like "the
  # lock key still uses the old lock screen".
  for attempt in 1 2; do
    result=$(timeout 5 "$cornice_bin" ipc lock lock 2>/dev/null || true)
    case "$result" in
      ok|already-locked) exit 0 ;;
    esac
    sleep 0.3
  done
  logger -t cornice-lock "cornice refused to lock (last result: ${result:-timeout}); falling back to hyprlock" 2>/dev/null || true
fi

if pgrep -x hyprlock >/dev/null 2>&1; then
  exit 0
fi

exec hyprlock
