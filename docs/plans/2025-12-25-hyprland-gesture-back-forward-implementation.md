# Hyprland Gesture Back/Forward Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Enable two-finger swipe left/right to trigger back/forward via `wtype` on Wayland.

**Architecture:** Keep `libinput-gestures` for gesture detection and replace `xdotool` actions with `wtype` key injection. Bind two-finger horizontal swipe to `Alt+Left/Alt+Right`, optional three-finger fallback.

**Tech Stack:** libinput-gestures, wtype, Hyprland

### Task 1: Update libinput-gestures bindings

**Files:**
- Modify: `libinput/libinput-gestures.conf`

**Step 1: Write the failing test**

Skip (config-only change; no test harness). Requires user approval to skip TDD.

**Step 2: Run test to verify it fails**

Skip (see Step 1).

**Step 3: Write minimal implementation**

- Replace `xdotool` invocations with `wtype` for two-finger swipe:
  - `gesture swipe left 2  wtype -M alt -k Right -m alt`
  - `gesture swipe right 2 wtype -M alt -k Left -m alt`
- Keep existing three-finger bindings as fallback (or adjust to `wtype` if requested).

**Step 4: Run test to verify it passes**

Manual verification:
- Run `libinput-gestures-setup restart`
- Focus Chrome and swipe left/right with two fingers; confirm back/forward

**Step 5: Commit**

```bash
git add libinput/libinput-gestures.conf
git commit -m "feat: use wtype for swipe back/forward"
```
