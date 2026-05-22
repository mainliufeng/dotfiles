---
name: chrome-access-routing
description: Route Chrome and browser-access tasks across macOS, Linux, Chrome Extension, Computer Use, Chrome DevTools Protocol, Browser, web-access, and headless/browser MCP tools. Use when the user asks Codex to open, inspect, control, screenshot, QA, or debug Chrome/browser pages, especially when one access method fails and another should be tried before giving up.
---

# Chrome Access Routing

## Overview

Use this skill to choose the right browser-access route instead of assuming a single Chrome method is authoritative. Treat failures as route-specific until other suitable routes have been tried.

## Routing Rules

1. Inspect the user's environment and requested surface first: macOS desktop Chrome, Linux headless/remote, localhost app, production URL, authenticated page, current visible tab, or generic web research.
2. Prefer the least disruptive route that can observe the needed evidence.
3. If one route fails, name the failed route and try the next reasonable route before asking the user to repair configuration.
4. Do not confuse different connection states. A Chrome Extension popup showing `Connected` does not mean Chrome DevTools Protocol is listening on `127.0.0.1:9222`, and a DevTools failure does not prove Computer Use or the extension is unavailable.
5. When using Computer Use on macOS, also use `computer-use-non-disruptive` if available. Call `get_app_state` first, verify the returned window/title/URL, and avoid switching workspaces or raising windows unless the user explicitly allows disruption.

## macOS Priority

For the user's Mac, prefer this order for visible Chrome pages:

1. **Computer Use for Google Chrome** when the user wants Codex to look at or operate the currently visible/real Chrome window. Use `get_app_state` first. This works even when Chrome DevTools Protocol is not enabled.
2. **Chrome Extension / Chrome plugin tools** when tools such as tab listing, tab claiming, screenshots, DOM reads, or Playwright-like control are actually exposed in the current tool list.
3. **Browser / in-app browser tools** for local app QA when the target URL is known and the user does not specifically need their real Chrome profile, cookies, extensions, or already-open tabs.
4. **Chrome DevTools Protocol** only when CDP tools are exposed and Chrome is listening on the expected debugging port, commonly `127.0.0.1:9222`. If this fails with `Failed to fetch browser webSocket URL`, explain that CDP is not enabled and try Computer Use or another route.
5. **Shell/curl/static inspection** only for non-visual checks such as HTTP status, sitemap, robots, metadata, build output, and generated HTML.

## Linux / Remote Priority

For Linux, SSH, containers, or remote hosts, prefer non-GUI routes first:

1. Use `web-access` for internet search, page retrieval, scraping, and network-facing web interaction.
2. Use headless browser or project browser skills when available for local/remote app QA.
3. Use shell checks (`curl`, app logs, tests, static HTML) for status and metadata.
4. Use desktop Computer Use only if a graphical browser is actually available and the user asks for that surface.

## Failure Handling

Use this diagnosis language:

- `Chrome Extension connected` means the browser extension is present and connected to Codex, but the agent still needs matching callable tools in the current session.
- `Chrome DevTools Protocol unavailable` means the debugging endpoint is not listening, usually because Chrome was not launched with `--remote-debugging-port=9222`.
- `Computer Use available` means Codex can inspect and operate the app UI through accessibility/screenshot state, but it may be less precise than DOM/Playwright/CDP for console, network, and structured DOM assertions.

Do not stop after a single failure unless the user only asked for that route. Report route-specific failure and continue with the next viable route.

## Prompt Pattern

When a browser task starts, reason internally with:

```text
Need to inspect/control Chrome or a web page.
First choose the route by surface:
- macOS real Chrome/current tab: use Computer Use get_app_state first.
- Authenticated/profile-dependent Chrome tab: try Chrome extension/plugin tools if exposed; otherwise Computer Use.
- Local app QA where real Chrome is not required: use Browser/in-app browser or headless browser.
- Linux/remote/non-GUI: use web-access/headless/curl before desktop assumptions.
- CDP only if DevTools tools are exposed and 127.0.0.1:9222 is listening.
If the first route fails, name that route and try the next viable route before asking the user to fix setup.
```
