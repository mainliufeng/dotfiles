# Hyprland Gesture Back/Forward Design

## Goal
Enable three-finger swipe left/right to trigger back/forward in Chrome (Wayland) and other apps that honor Alt+Left/Alt+Right, using the existing dotfiles stack.

## Current State
- Hyprland starts `libinput-gestures` via `exec-once` in `hyprland.conf`.
- `libinput-gestures.conf` uses `xdotool`, which is X11-only and does not work for Wayland-native Chrome.

## Proposed Approach
Keep `libinput-gestures` for gesture detection and replace `xdotool` with `wtype` for Wayland-compatible key injection. Bind three-finger horizontal swipe to `Alt+Left` and `Alt+Right`.

## Configuration Changes
- Update `libinput/libinput-gestures.conf`:
  - `gesture swipe left 3`  -> `wtype -M alt -k Right -m alt`
  - `gesture swipe right 3` -> `wtype -M alt -k Left -m alt`

## Data Flow
Touchpad gesture -> `libinput-gestures` recognizes swipe -> executes `wtype` -> Wayland virtual keyboard sends `Alt+Left/Alt+Right` to focused app.

## Error Handling
- If `wtype` is missing or the virtual-keyboard protocol is unavailable, gestures will do nothing. Verify `wtype` exists and works in the session.
- Two-finger horizontal movement remains scrolling; no gesture mapping is attached to two fingers.

## Verification
- Restart `libinput-gestures` and open Chrome or a file manager.
- Confirm three-finger swipe left/right triggers back/forward.
- Manually run `wtype -M alt -k Left -m alt` in a focused window to verify key injection.
