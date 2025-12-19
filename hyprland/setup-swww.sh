#!/usr/bin/env bash
set -euo pipefail

echo "[swww] Deprecated: moved to ~/dotfiles/swww/setup.sh" >&2

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
exec "${script_dir}/../swww/setup.sh" "$@"
