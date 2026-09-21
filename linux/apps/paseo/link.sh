#!/usr/bin/env bash
set -euo pipefail

module_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
autostart_dir="${XDG_CONFIG_HOME:-$HOME/.config}/autostart"
bin_dir="$HOME/.local/bin"
applications_dir="${XDG_DATA_HOME:-$HOME/.local/share}/applications"

# `paseo-bin` installs /usr/bin/paseo as the Electron *GUI* wrapper: every
# invocation boots the app and opens a window, even when the arguments are CLI
# subcommands (`paseo ls`, `paseo run`, ...). Agents read the bundled `paseo`
# skill and call the CLI through scripts, so a burst of `paseo` calls used to
# paint the screen with windows.
#
# The app also ships the real CLI at /opt/Paseo/resources/bin/paseo, which runs
# the same code as plain Node (ELECTRON_RUN_AS_NODE=1) and never touches the GUI.
# Since ~/.local/bin precedes /usr/bin in PATH — for the session and for every
# agent the daemon spawns — shadowing the name there fixes CLI callers without
# patching Paseo's own skills (they are Paseo-managed and get rewritten).
# The GUI stays reachable as `paseo-gui` and from the applications menu, which
# uses the absolute-path override linked below.
paseo_gui="/usr/bin/paseo"
paseo_cli="/opt/Paseo/resources/bin/paseo"

links=("$module_dir/paseo-daemon.desktop:$autostart_dir/paseo-daemon.desktop")
links+=("$module_dir/paseo.desktop:$applications_dir/paseo.desktop")

if [[ -x "$paseo_cli" && -x "$paseo_gui" ]]; then
  links+=("$paseo_cli:$bin_dir/paseo")
  links+=("$paseo_gui:$bin_dir/paseo-gui")
else
  echo "[paseo] ${paseo_cli} or ${paseo_gui} missing; skipping the CLI/PATH links" >&2
fi

if [[ "${DOTFILES_DRY_RUN:-0}" == "1" ]]; then
  for link in "${links[@]}"; do
    echo "[dry-run] ln -sfn ${link%%:*} ${link#*:}"
  done
  exit 0
fi

for link in "${links[@]}"; do
  source_file="${link%%:*}"
  target_file="${link#*:}"
  mkdir -p "$(dirname "$target_file")"
  ln -sfn "$source_file" "$target_file"
  echo "[paseo] linked: $target_file -> $source_file"
done
