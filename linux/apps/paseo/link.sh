#!/usr/bin/env bash
set -euo pipefail

module_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_file="$module_dir/paseo-daemon.desktop"
autostart_dir="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
target_file="$autostart_dir/paseo-daemon.desktop"

if [[ "${DOTFILES_DRY_RUN:-0}" == "1" ]]; then
  echo "[dry-run] ln -sfn $source_file $target_file"
  exit 0
fi

mkdir -p "$autostart_dir"
ln -sfn "$source_file" "$target_file"
echo "[paseo] linked autostart entry: $target_file"
