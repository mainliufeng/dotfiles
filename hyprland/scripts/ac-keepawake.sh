#!/usr/bin/env bash
set -euo pipefail

STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/waybar-ac-keepawake"
PID_FILE="$STATE_DIR/inhibitor.pid"
ENABLED_FILE="$STATE_DIR/enabled"

mkdir -p "$STATE_DIR"

is_ac_online() {
  local ps type online
  for ps in /sys/class/power_supply/*; do
    [[ -d "$ps" ]] || continue
    [[ -r "$ps/type" && -r "$ps/online" ]] || continue
    type="$(<"$ps/type")"
    if [[ "$type" == "Mains" ]]; then
      online="$(<"$ps/online")"
      [[ "$online" == "1" ]] && return 0
    fi
  done
  return 1
}

is_enabled() {
  [[ -f "$ENABLED_FILE" ]] || set_enabled 1
  [[ -f "$ENABLED_FILE" ]] && [[ "$(<"$ENABLED_FILE")" == "1" ]]
}

set_enabled() {
  local value="${1:-1}"
  printf '%s\n' "$value" >"$ENABLED_FILE"
}

has_inhibitor_pid() {
  [[ -f "$PID_FILE" ]] || return 1
  local pid
  pid="$(<"$PID_FILE")"
  [[ "$pid" =~ ^[0-9]+$ ]] || return 1
  kill -0 "$pid" 2>/dev/null
}

is_inhibitor_running() {
  has_inhibitor_pid || return 1
  local pid cmdline
  pid="$(<"$PID_FILE")"
  [[ -r "/proc/$pid/cmdline" ]] || return 1
  cmdline="$(tr '\0' ' ' <"/proc/$pid/cmdline")"
  [[ "$cmdline" == *"systemd-inhibit"* ]] && [[ "$cmdline" == *"waybar-ac-keepawake"* ]]
}

start_inhibitor() {
  is_inhibitor_running && return 0
  command -v systemd-inhibit >/dev/null 2>&1 || return 1

  systemd-inhibit \
    --what=idle:sleep:handle-lid-switch \
    --mode=block \
    --why="waybar-ac-keepawake" \
    bash -c 'exec -a waybar-ac-keepawake sleep infinity' \
    >/dev/null 2>&1 &

  printf '%s\n' "$!" >"$PID_FILE"
}

stop_inhibitor() {
  has_inhibitor_pid || {
    rm -f "$PID_FILE"
    return 0
  }

  local pid
  pid="$(<"$PID_FILE")"
  kill "$pid" 2>/dev/null || true
  rm -f "$PID_FILE"
}

sync_inhibitor() {
  if is_enabled && is_ac_online; then
    start_inhibitor || true
  else
    stop_inhibitor
  fi
}

print_status_json() {
  local enabled=0 ac=0 running=0 text tooltip class

  is_enabled && enabled=1
  is_ac_online && ac=1
  is_inhibitor_running && running=1

  if (( enabled == 0 )); then
    text=""
    tooltip="AC keep-awake: off (click to enable)"
    class="off"
  elif (( ac == 0 )); then
    text=""
    tooltip="AC keep-awake: armed (waiting for AC power)"
    class="armed"
  elif (( running == 1 )); then
    text=""
    tooltip="AC keep-awake: active (sleep/lid sleep blocked on AC)"
    class="active-ac"
  else
    text=""
    tooltip="AC keep-awake: failed to start inhibitor"
    class="error"
  fi

  printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$tooltip" "$class"
}

status() {
  sync_inhibitor
  print_status_json
}

toggle() {
  if is_enabled; then
    set_enabled 0
  else
    set_enabled 1
  fi
  sync_inhibitor
}

main() {
  local cmd="${1:-status}"

  case "$cmd" in
    status) status ;;
    toggle) toggle ;;
    on) set_enabled 1; sync_inhibitor ;;
    off) set_enabled 0; sync_inhibitor ;;
    *)
      echo "Usage: $(basename "$0") [status|toggle|on|off]" >&2
      exit 2
      ;;
  esac
}

main "$@"
