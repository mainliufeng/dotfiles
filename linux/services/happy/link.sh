#!/usr/bin/env bash
set -euo pipefail

module_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_file="$module_dir/happy.service"
unit_dir="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
target_file="$unit_dir/happy.service"

if [[ "${DOTFILES_DRY_RUN:-0}" == "1" ]]; then
  echo "[dry-run] ln -sfn $source_file $target_file"
  exit 0
fi

mkdir -p "$unit_dir"
ln -sfn "$source_file" "$target_file"
systemctl --user daemon-reload
echo "[happy] linked unit: $target_file"
