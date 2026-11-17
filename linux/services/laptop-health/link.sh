#!/usr/bin/env bash
set -euo pipefail
base="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
mkdir -p "$HOME/.local/bin" "$HOME/.config/systemd/user" "$HOME/.config/laptop-health"
ln -sfn "$base/healthctl.py" "$HOME/.local/bin/healthctl"
ln -sfn "$base/heartbeat.sh" "$HOME/.local/bin/health-heartbeat"
ln -sfn "$base/agent_worker.py" "$HOME/.local/bin/health-agent-worker"
for f in "$base"/*.service "$base"/*.timer; do ln -sfn "$f" "$HOME/.config/systemd/user/$(basename "$f")"; done
if [[ ! -e "$HOME/.config/laptop-health/config.json" ]]; then
  if [[ -f "$HOME/dotfiles-private/health/hosts/$(hostname).json" ]]; then
    ln -s "$HOME/dotfiles-private/health/hosts/$(hostname).json" "$HOME/.config/laptop-health/config.json"
  else
    cp "$base/defaults.json" "$HOME/.config/laptop-health/config.json"
  fi
fi
