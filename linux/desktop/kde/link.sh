#!/usr/bin/env sh
set -eu

# Krohnkite default puts tiled windows on the "below" layer (tiledWindowsLayer=0),
# which can make keyboard focus changes (e.g. Meta+J) appear to not raise the
# newly-focused window. Force tiled windows to use the normal layer.
if command -v kwriteconfig6 >/dev/null 2>&1; then
  kwriteconfig6 --file kwinrc --group Script-krohnkite --key tiledWindowsLayer 1
  kwriteconfig6 --file kwinrc --group Script-krohnkite --key floatedWindowsLayer 1
  kwriteconfig6 --file kwinrc --group Plugins --key zoomEnabled --type bool false
  kwriteconfig6 --file kwinrc --group Effect-zoom --key InitialZoom 1
  kwriteconfig6 --file kwinrc --group Wayland --key InputMethod /usr/share/applications/org.fcitx.Fcitx5.desktop
  kwriteconfig6 --file kwinrc --group Wayland --key VirtualKeyboardEnabled --type bool true
else
  echo "kwriteconfig6 not found; cannot configure KWin" >&2
fi
