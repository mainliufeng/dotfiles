#!/usr/bin/env bash
# Idle helpers, kept AC-aware so the Hyprland session behaves like KDE's
# PowerDevil profile the user configured:
#
#   AC       dim 60s, display off 120s, never suspend
#   Battery  display off 300s, never suspend
#
# logind's IdleAction is left at its default (ignore) and nothing here ever
# suspends — the machine only sleeps when asked.
set -euo pipefail

action="${1:-}"
shift || true
mode="any"          # any | ac | battery
dry=0
for arg in "$@"; do
  case "$arg" in
    --if-ac) mode="ac" ;;
    --if-battery) mode="battery" ;;
    --dry-run) dry=1 ;;
  esac
done

ac_state() {
  local supply
  for supply in /sys/class/power_supply/A*/online; do
    [[ -r $supply ]] || continue
    [[ $(cat "$supply") == "1" ]] && { echo "ac"; return; }
  done
  echo "battery"
}

state=$(ac_state)
case "$mode" in
  ac) [[ $state == "ac" ]] || { echo "skip: on $state"; exit 0; } ;;
  battery) [[ $state == "battery" ]] || { echo "skip: on $state"; exit 0; } ;;
esac

runtime="${XDG_RUNTIME_DIR:-/tmp}"
dim_file="$runtime/cornice-idle-dim"

case "$action" in
  dim)
    if [[ -f $dim_file ]]; then echo "already dimmed"; exit 0; fi
    command -v light >/dev/null 2>&1 || { echo "no light(1)"; exit 0; }
    current=$(light -G 2>/dev/null || echo "")
    [[ -n $current ]] || exit 0
    if ((dry)); then echo "would dim from $current to 20%"; exit 0; fi
    printf '%s\n' "$current" >"$dim_file"
    light -S 20
    echo "dimmed"
    ;;

  undim)
    [[ -f $dim_file ]] || { echo "not dimmed"; exit 0; }
    previous=$(cat "$dim_file")
    if ((dry)); then echo "would restore $previous"; exit 0; fi
    rm -f "$dim_file"
    light -S "$previous" 2>/dev/null || true
    echo "restored"
    ;;

  display-off)
    if ((dry)); then echo 'would run: hyprctl dispatch hl.dsp.dpms({action="off"})'; exit 0; fi
    hyprctl dispatch 'hl.dsp.dpms({action="off"})' >/dev/null 2>&1 || true
    echo "display off"
    ;;

  display-on)
    if ((dry)); then echo 'would run: hyprctl dispatch hl.dsp.dpms({action="on"})'; exit 0; fi
    hyprctl dispatch 'hl.dsp.dpms({action="on"})' >/dev/null 2>&1 || true
    echo "display on"
    ;;

  *)
    echo "usage: $(basename "$0") dim|undim|display-off|display-on [--if-ac|--if-battery] [--dry-run]" >&2
    exit 2
    ;;
esac
