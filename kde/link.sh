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
else
  echo "kwriteconfig6 not found; cannot configure Krohnkite layers" >&2
fi
