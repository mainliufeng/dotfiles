#!/bin/sh
# Independent of Python source, SQLite and agent imports. Never repairs anything.
set -eu
state=${HEALTH_STATE:-"$HOME/.local/state/laptop-health"}
mkdir -p "$state"
now=$(date +%s)
last=$(stat -c %Y "$state/heartbeat" 2>/dev/null || printf 0)
age=$((now-last))
if [ "$age" -ge 0 ] && [ "$age" -lt 180 ]; then
  printf 'Laptop health heartbeat fresh (%s seconds).\n' "$age"
  exit 0
fi
printf 'Laptop health heartbeat stale/missing (%s seconds). Collection may have failed.\n' "$age" >&2
notified=$(stat -c %Y "$state/heartbeat-alert" 2>/dev/null || printf 0)
if [ $((now-notified)) -ge 1800 ]; then
  if notify-send --app-name='Laptop Health' 'Laptop monitor stalled' 'Collector heartbeat is stale or missing. No automatic repair performed.'; then
    touch "$state/heartbeat-alert"
  else
    printf 'Desktop notification failed; next heartbeat will retry.\n' >&2
  fi
fi
exit 1
