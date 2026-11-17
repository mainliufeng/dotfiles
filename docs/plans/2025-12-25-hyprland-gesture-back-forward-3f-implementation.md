# Hyprland Gesture Back/Forward (Three-Finger) Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Switch back/forward gesture to three-finger swipe on Wayland using `wtype`.

**Architecture:** Keep `libinput-gestures` for gesture detection and use `wtype` to send `Alt+Left/Alt+Right` on three-finger swipes. Remove the non-functional two-finger swipe bindings.

**Tech Stack:** libinput-gestures, wtype, Hyprland

### Task 1: Update libinput-gestures bindings

**Files:**
- Modify: `libinput/libinput-gestures.conf`

**Step 1: Write the failing test**

Skip (config-only change; no test harness). Requires user approval to skip TDD.

**Step 2: Run test to verify it fails**

Skip (see Step 1).

**Step 3: Write minimal implementation**

- Remove two-finger swipe bindings:
  - `gesture swipe left 2  wtype -M alt -k Right -m alt`
  - `gesture swipe right 2 wtype -M alt -k Left -m alt`
- Update three-finger swipe bindings to use `wtype`:
  - `gesture swipe left 3  wtype -M alt -k Right -m alt`
  - `gesture swipe right 3 wtype -M alt -k Left -m alt`

**Step 4: Run test to verify it passes**

Manual verification:
- Run `libinput-gestures-setup restart`
- Focus Chrome and swipe left/right with three fingers; confirm forward/back

**Step 5: Commit**

```bash
git add libinput/libinput-gestures.conf
git commit -m "feat: move back/forward to three-finger swipe"
```
