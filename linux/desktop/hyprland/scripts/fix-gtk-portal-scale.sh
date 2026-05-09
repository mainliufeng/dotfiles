#!/usr/bin/env bash
set -euo pipefail

# Hyprland already applies output scaling via monitor scale (e.g. 2x).
# If GNOME/GTK gsettings scaling is also set to 2, GTK file choosers (e.g. portal-gtk)
# can get scaled twice and appear huge.

gsettings set org.gnome.desktop.interface scaling-factor 1
gsettings set org.gnome.desktop.interface text-scaling-factor 1.0

