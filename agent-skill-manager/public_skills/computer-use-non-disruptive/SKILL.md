---
name: computer-use-non-disruptive
description: Use before any Computer Use / @Computer / desktop app GUI operation, especially on macOS with Spaces/workspaces, multiple windows, background apps, or when the user asks not to be interrupted. Enforces non-disruptive Computer Use: do not switch workspace/window, do not activate apps, and prefer app accessibility-tree element operations.
---

# Computer Use Non-Disruptive Guard

Use this skill before any Computer Use / `@Computer` / desktop app GUI operation.

Goal: operate the target app without disturbing the user's current workspace, active window, or typing focus.

## Mental Model

Computer Use has two layers. Keep them separate.

### Layer 1: Global Window / Workspace Orchestration

This layer changes global focus and usually disturbs the user.

Examples:

- Switching workspace / Space / Desktop.
- Switching windows with `Command-Tab`, Dock, Mission Control, F3, or `Control+number`.
- Activating an app with AppleScript `activate`.
- Opening or creating a foreground window with `open`, `open -a`, `open -na`, or app-specific window commands.
- Using scripts that make a target window active or bring it to front.
- Clicking Dock, menu bar, title bar, Mission Control, or other system-level UI.

Do not use this layer unless the user explicitly allows interruption.

### Layer 2: App Accessibility Operation

This is the preferred non-disruptive path.

Use Computer Use with only the app name or bundle id:

```json
{"app":"Safari"}
{"app":"Google Chrome"}
```

Then operate elements from the returned accessibility tree:

- `click` by `element_index`
- `type_text`
- `press_key`
- `set_value`

This can operate an app/window that is not in the user's current active workspace. It can click and type without switching workspace, if Computer Use returns the intended app window.

## Important Limits

- Computer Use can specify an app, not a workspace.
- Computer Use can specify an app, not a particular window.
- If an app has multiple windows, `get_app_state(app=...)` usually returns the app's key / focused / recently used / accessibility-selected window.
- Best case: the target app has only one window, or the target window is already the app's most recent/key accessibility window.
- If the returned tree is not the intended window, stop. Do not switch workspace to find it.
- Some apps are blocked by safety policy. Example observed: Ghostty / `com.mitchellh.ghostty`.

## Required Workflow

1. Call `get_app_state` for the target app before any action.
2. Inspect and report internally:
   - window title
   - URL, if browser
   - selected tab, if available
   - key elements relevant to the task
3. Decide whether the returned tree is the target.
4. If it matches, operate only by accessibility element indexes.
5. After each action, use the returned state or call `get_app_state` again to verify.
6. If it does not match, stop and tell the user:
   - what window/title/URL was returned
   - that Computer Use can only target app-level recent/key accessibility windows
   - that it cannot directly specify workspace/window

## Hard Prohibitions

Unless the user explicitly allows interruption, do not:

- switch workspace / Space / Desktop
- send `Control+number`, `Control+arrow`, F3, or Mission Control
- use `Command-Tab`
- click Dock, menu bar, title bar, or Mission Control
- `activate` the target app
- use `open`, `open -a`, or `open -na` to create/raise a foreground window
- use AppleScript or shell commands that bring a window to front
- ask the user to click the target window to make it recent
- guess workspace numbering

If the task requires opening a new app/window in another workspace, explain that this usually requires global window management and may interrupt the user. Do not proceed unless the user accepts that interruption.

## Safe Prompt Pattern

When operating via Computer Use, follow this instruction:

```text
Use Computer Use for the target app without disturbing the user's current workspace.

Use only the app accessibility operation layer.
Do not switch workspace, switch windows, activate apps, use open/open -a/open -na, click Dock/menu/title bar, use Mission Control, or run scripts that bring windows to front.

First call get_app_state with only the app name or bundle id.
Check the returned window title, URL, selected tab, and relevant elements.
If it is the intended window, operate only by element_index using click/type_text/press_key/set_value.
If it is not the intended window, stop and report the returned title/URL and the limitation that Computer Use cannot directly specify workspace/window.

Prefer targets where the app has only one window, or where the intended window is already the app's most recent/key accessibility window.
```

