#!/usr/bin/env bash
# deepseek-harness — install the DeepSeek Harness desktop wrapper (macOS & Linux).
#
# Installs:
#   - the `dsh-app` CLI launcher (linked onto PATH via link.sh)
#   - a desktop "app" that opens the web UI in the default browser:
#       * macOS: a native .app bundle in ~/Applications
#       * Linux: a .desktop entry in ~/.local/share/applications
#
# The web server itself (`@deepseek-ai/dsh`) is fetched on demand via npx the
# first time you launch it, so no heavy pre-download is required here.
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_NAME="DeepSeek Harness"
APP_SLUG="deepseek-harness"
LAUNCHER="$ROOT_DIR/bin/dsh-app"

log()  { printf '[deepseek-harness] %s\n' "$*"; }
die()  { printf '[deepseek-harness] error: %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# macOS: build a self-contained .app with a native WKWebView window (no browser,
# no Electron). It compiles the Swift shell with the system toolchain (swiftc),
# which ships with Xcode Command Line Tools / the macOS SDK.
# ---------------------------------------------------------------------------
install_macos_app() {
  local app_dir="$HOME/Applications/$APP_NAME.app"
  local contents="$app_dir/Contents"
  local macos_dir="$contents/MacOS"
  local resources="$contents/Resources"

  mkdir -p "$macos_dir" "$resources"

  # Compile the Swift wrapper to the bundle's native executable.
  local swift_src="$ROOT_DIR/src/deepseek-harness.swift"
  local bin="$macos_dir/deepseek-harness"
  if ! command -v swiftc >/dev/null 2>&1; then
    die "swiftc not found — install Xcode Command Line Tools (xcode-select --install)"
  fi
  swiftc -O -o "$bin" "$swift_src" -framework Cocoa -framework WebKit
  chmod +x "$bin"

  # Info.plist
  cat > "$contents/Info.plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleDisplayName</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>dev.mainliufeng.$APP_SLUG</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleExecutable</key>
    <string>deepseek-harness</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>LSMinimumSystemVersion</key>
    <string>11.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>NSAppTransportSecurity</key>
    <dict>
        <key>NSAllowsLocalNetworking</key>
        <true/>
        <key>NSAllowsArbitraryLoads</key>
        <true/>
    </dict>
</dict>
</plist>
EOF

  # Icon: convert the SVG to an .icns via the system `sips`/`iconutil` toolchain.
  local icon_svg="$ROOT_DIR/assets/icon.svg"
  if [[ -f "$icon_svg" ]]; then
    build_icns "$icon_svg" "$resources/AppIcon.icns" || log "icon conversion skipped (AppIcon missing)"
  fi

  log "installed macOS app -> $app_dir"
}

# Convert an SVG asset into an .icns file using qlmanage/sips + iconutil.
build_icns() {
  local svg="$1" out_icns="$2"
  local work iconset
  work="$(mktemp -d)"
  iconset="$work/AppIcon.iconset"
  mkdir -p "$iconset"

  local render_png
  render_png() {
    # Render SVG to a large PNG, then resize per size.
    local size="$1" out="$2"
    # qlmanage renders a thumbnail of the SVG; fall back to sips if needed.
    (cd "$work" && qlmanage -t -s "$size" -o "$work" "$svg" >/dev/null 2>&1 || true)
    local rendered
    rendered="$(find "$work" -maxdepth 1 -name '*.png' | head -1)"
    if [[ -z "$rendered" ]]; then
      return 1
    fi
    sips -z "$size" "$size" "$rendered" --out "$out" >/dev/null 2>&1
    rm -f "$rendered"
  }

  render_png 1024 "$iconset/icon_512x512@2x.png" || return 1
  sips -z 512 512 "$iconset/icon_512x512@2x.png" --out "$iconset/icon_512x512.png" >/dev/null 2>&1
  sips -z 256 256 "$iconset/icon_512x512.png" --out "$iconset/icon_256x256.png" >/dev/null 2>&1
  sips -z 128 128 "$iconset/icon_256x256.png" --out "$iconset/icon_128x128.png" >/dev/null 2>&1
  cp "$iconset/icon_256x256.png" "$iconset/icon_128x128@2x.png"
  cp "$iconset/icon_512x512.png" "$iconset/icon_256x256@2x.png"
  cp "$iconset/icon_128x128.png" "$iconset/icon_32x32@2x.png"
  sips -z 64 64 "$iconset/icon_256x256.png" --out "$iconset/icon_32x32.png" >/dev/null 2>&1
  sips -z 32 32 "$iconset/icon_128x128.png" --out "$iconset/icon_16x16.png" >/dev/null 2>&1
  cp "$iconset/icon_32x32.png" "$iconset/icon_16x16@2x.png"

  iconutil -c icns "$iconset" -o "$out_icns" >/dev/null 2>&1
  rm -rf "$work"
}

# ---------------------------------------------------------------------------
# Linux: install a .desktop entry.
# ---------------------------------------------------------------------------
install_linux_app() {
  # The C shell is written against the GTK3 API, so we use webkit2gtk-4.1
  # (Arch's GTK3 binding). GTK4's webkitgtk-6.0 has an incompatible API and is
  # not supported here.
  local webkit_pkg="webkit2gtk-4.1"
  local pkgconfig_name="webkit2gtk-4.1"

  # Install the WebKitGTK + compiler toolchain if missing.
  local need_install=0
  if ! pacman -Q "$webkit_pkg" >/dev/null 2>&1; then need_install=1; fi
  if ! command -v gcc >/dev/null 2>&1; then need_install=1; fi
  if ! pkg-config --exists gtk+-3.0 "$pkgconfig_name" 2>/dev/null; then
    need_install=1
  fi

  if [[ "$need_install" == "1" ]]; then
    local installer=(sudo pacman -S --needed "$webkit_pkg" base-devel)
    log "installing: ${installer[*]}"
    "${installer[@]}" || die "failed to install $webkit_pkg — run manually"
  fi

  # Compile the native shell into ~/.local/bin.
  local bin="$HOME/.local/bin/deepseek-harness"
  local c_src="$ROOT_DIR/src/deepseek-harness.c"
  local cflags libs
  cflags="$(pkg-config --cflags gtk+-3.0 "$pkgconfig_name")"
  libs="$(pkg-config --libs gtk+-3.0 "$pkgconfig_name")"
  gcc -O2 -o "$bin" "$c_src" $cflags $libs
  chmod +x "$bin"

  install_linux_desktop "$bin"
}

install_linux_desktop() {
  local exec_bin="$1"
  local apps_dir="$HOME/.local/share/applications"
  local desk="$apps_dir/$APP_SLUG.desktop"
  mkdir -p "$apps_dir"
  mkdir -p "$HOME/.local/share/icons/hicolor/256x256/apps"

  # Icon: try to convert SVG -> PNG via rsvg-convert/inkscape/imagemagick, else
  # ship the SVG directly (most desktop environments render SVG icons fine).
  local icon_svg="$ROOT_DIR/assets/icon.svg"
  local icon_path
  if command -v rsvg-convert >/dev/null 2>&1; then
    icon_path="$HOME/.local/share/icons/hicolor/256x256/apps/$APP_SLUG.png"
    rsvg-convert -w 256 -h 256 "$icon_svg" -o "$icon_path" 2>/dev/null || icon_path="$icon_svg"
  else
    icon_path="$icon_svg"
  fi

  cat > "$desk" <<EOF
[Desktop Entry]
Type=Application
Name=$APP_NAME
Comment=DeepSeek Harness web UI
Exec=$exec_bin
Icon=$icon_path
Terminal=false
Categories=Development;Utility;
StartupWMClass=$APP_SLUG
EOF
  chmod +x "$desk"

  if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$apps_dir" >/dev/null 2>&1 || true
  fi

  log "installed Linux desktop app -> $desk"
}

# ---------------------------------------------------------------------------

case "$(uname -s)" in
  Darwin)
    "$ROOT_DIR/link.sh"
    mkdir -p "$HOME/Applications"
    install_macos_app
    ;;
  Linux)
    "$ROOT_DIR/link.sh"
    install_linux_app
    ;;
  *)
    echo "[deepseek-harness] unsupported platform: $(uname -s)" >&2
    exit 1
    ;;
esac

log "done. Launch via: dsh-app  (or the desktop app)."
