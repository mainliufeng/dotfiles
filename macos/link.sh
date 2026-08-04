#!/usr/bin/env bash
set -euo pipefail

mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/Applications"

for script in "$HOME"/dotfiles/macos/bin/*; do
  [[ -f "$script" ]] || continue
  chmod +x "$script"
  ln -svfn "$script" "$HOME/.local/bin/$(basename "$script")"
done

mkdir -p "$HOME/.config/htop"
ln -svfn "$HOME/dotfiles/macos/htoprc" "$HOME/.config/htop/htoprc"

watchdog_label="com.mainliufeng.codex-app-watchdog"
watchdog_template="$HOME/dotfiles/macos/launchd/${watchdog_label}.plist"
watchdog_dest="$HOME/Library/LaunchAgents/${watchdog_label}.plist"
watchdog_log_dir="$HOME/Library/Logs/$watchdog_label"

if [[ -f "$watchdog_template" ]]; then
  mkdir -p "$HOME/Library/LaunchAgents" "$watchdog_log_dir"
  sed \
    -e "s|__WATCHDOG__|$HOME/.local/bin/codex-app-watchdog|g" \
    -e "s|__LOG_DIR__|$watchdog_log_dir|g" \
    "$watchdog_template" > "$watchdog_dest"
  plutil -lint "$watchdog_dest"
  launchctl bootout "gui/$UID/$watchdog_label" >/dev/null 2>&1 || true
  launchctl bootstrap "gui/$UID" "$watchdog_dest"
  launchctl enable "gui/$UID/$watchdog_label"
  launchctl kickstart "gui/$UID/$watchdog_label"
  echo "[macos] installed Codex app watchdog: $watchdog_dest"
fi

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
unset codex_icon dest_app watchdog_label watchdog_template watchdog_dest watchdog_log_dir

codex_cli="/Applications/Codex.app/Contents/Resources/codex"
if [[ -x "$codex_cli" && ! -e "$HOME/.local/bin/codex" ]]; then
  ln -s "$codex_cli" "$HOME/.local/bin/codex"
  echo "[macos] linked Codex CLI -> $HOME/.local/bin/codex"
elif [[ -x "$codex_cli" ]]; then
  echo "[macos] Codex CLI available: $codex_cli"
fi

echo "[macos] link complete"
