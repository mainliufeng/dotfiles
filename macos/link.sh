#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/Applications"

for script in "$HOME"/dotfiles/macos/bin/*; do
  [[ -f "$script" ]] || continue
  chmod +x "$script"
  ln -svfn "$script" "$HOME/.local/bin/$(basename "$script")"
done

for app in "$HOME"/dotfiles/macos/apps/*.app; do
  [[ -d "$app" ]] || continue
  find "$app/Contents/MacOS" -type f -exec chmod +x {} \;
  dest_app="$HOME/Applications/$(basename "$app")"
  rm -rf "$dest_app"
  cp -R "$app" "$dest_app"
  find "$dest_app/Contents/MacOS" -type f -exec chmod +x {} \;
  codex_icon="/Applications/Codex.app/Contents/Resources/electron.icns"
  if [[ -f "$codex_icon" ]]; then
    mkdir -p "$dest_app/Contents/Resources"
    cp "$codex_icon" "$dest_app/Contents/Resources/electron.icns"
  fi
  touch "$dest_app"
  echo "[macos] installed app: $dest_app"
done
unset codex_icon dest_app

codex_cli="/Applications/Codex.app/Contents/Resources/codex"
if [[ -x "$codex_cli" && ! -e "$HOME/.local/bin/codex" ]]; then
  ln -s "$codex_cli" "$HOME/.local/bin/codex"
  echo "[macos] linked Codex CLI -> $HOME/.local/bin/codex"
elif [[ -x "$codex_cli" ]]; then
  echo "[macos] Codex CLI available: $codex_cli"
fi

echo "[macos] link complete"
