#!/usr/bin/env bash
set -euo pipefail
base="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
case "${1:-}" in
  --uninstall) systemctl --user disable --now laptop-health.timer laptop-health-heartbeat.timer laptop-health-agent.timer; echo 'Disabled timers. Configuration, evidence, and source retained.'; exit;;
  --check) python3 -m unittest discover -s "$base" -p 'test*.py'; exit;;
  '') ;;
  *) echo 'Usage: setup.sh [--check|--uninstall]' >&2; exit 2;;
esac
"$base/link.sh"
systemctl --user daemon-reload
systemctl --user enable --now laptop-health.timer laptop-health-heartbeat.timer
# Agent is optional and fails closed unless this host has a verified pinned runtime.
if python3 - "$base" <<'PYCODE'
import sys
sys.path.insert(0,sys.argv[1])
import codex_isolated
try:
    assert codex_isolated.validated_config().get('transport_verified')
except Exception:
    raise SystemExit(1)
PYCODE
then
  systemctl --user enable --now laptop-health-agent.timer
else
  echo 'Codex diagnosis remains disabled: no verified pinned runtime.'
fi
systemctl --user start laptop-health.service
"$HOME/.local/bin/healthctl" doctor
