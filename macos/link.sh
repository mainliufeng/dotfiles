#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/.local/bin"

for script in "$HOME"/dotfiles/macos/bin/*; do
  [[ -f "$script" ]] || continue
  ln -svfn "$script" "$HOME/.local/bin/$(basename "$script")"
done

codex_cli="/Applications/Codex.app/Contents/Resources/codex"
if [[ -x "$codex_cli" && ! -e "$HOME/.local/bin/codex" ]]; then
  ln -s "$codex_cli" "$HOME/.local/bin/codex"
  echo "[macos] linked Codex CLI -> $HOME/.local/bin/codex"
elif [[ -x "$codex_cli" ]]; then
  echo "[macos] Codex CLI available: $codex_cli"
fi

echo "[macos] link complete"
