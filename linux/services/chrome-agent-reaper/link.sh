#!/usr/bin/env bash
set -euo pipefail

module_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dotfiles_root="$(cd "$module_dir/../../.." && pwd)"

unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
bin_dir="$HOME/.local/bin"
reaper="$dotfiles_root/scripts/chrome-agent-reap"

if [[ "${DOTFILES_DRY_RUN:-0}" == "1" ]]; then
  echo "[dry-run] mkdir -p $unit_dir $bin_dir"
  echo "[dry-run] ln -sfn $reaper $bin_dir/chrome-agent-reap"
  for unit in chrome-agent-reaper.service chrome-agent-reaper.timer; do
    echo "[dry-run] ln -sfn $module_dir/$unit $unit_dir/$unit"
  done
  echo "[dry-run] systemctl --user daemon-reload"
  exit 0
fi

mkdir -p "$unit_dir" "$bin_dir"

# 命令行入口（agent 和人都可以直接跑），和 chrome-agent / chrome-agent-read 并列。
ln -sfn "$reaper" "$bin_dir/chrome-agent-reap"

for unit in chrome-agent-reaper.service chrome-agent-reaper.timer; do
  ln -sfn "$module_dir/$unit" "$unit_dir/$unit"
done

systemctl --user daemon-reload
echo "[chrome-agent-reaper] linked: $bin_dir/chrome-agent-reap + $unit_dir/chrome-agent-reaper.{service,timer}"
