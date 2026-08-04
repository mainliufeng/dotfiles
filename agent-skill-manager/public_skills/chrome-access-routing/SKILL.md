---
name: chrome-access-routing
description: Route Chrome, browser-access, and web-research tasks across Codex and Hermes on macOS or Linux, including Chrome Extension, Computer Use, Chrome DevTools Protocol, Browser, web-access, agent-browser, and headless/browser MCP tools. Use when the user asks an agent to research, open, inspect, control, screenshot, QA, or debug web pages, especially authenticated dashboards, the user's already-open Chrome tab, or cases where one route fails and another should be tried before giving up.
---

# Chrome Access Routing

## Overview

Use this skill to choose the right browser-access route instead of assuming a single Chrome method is authoritative. Treat failures as route-specific until other suitable routes have been tried.

## Routing Rules

1. Inspect the user's environment and requested surface first: macOS desktop Chrome, Linux headless/remote, localhost app, production URL, authenticated page, current visible tab, or generic web research.
2. Prefer the least disruptive route that can observe the needed evidence.
3. If one route fails, name the failed route and try the next reasonable route before asking the user to repair configuration.
4. Do not confuse different connection states. A Chrome Extension popup showing `Connected` does not mean Chrome DevTools Protocol is listening on `127.0.0.1:9222`, and a DevTools failure does not prove Computer Use or the extension is unavailable.
5. Do not confuse Chrome Extension profile state with the user's real visible Chrome state. If an extension/headless route shows Google account chooser, signed-out, blocked, empty shell, or a different profile, that is only evidence about that route.
6. When using Computer Use on macOS, also use `computer-use-non-disruptive` if available. Call `get_app_state` first, verify the returned window/title/URL, and avoid switching workspaces or raising windows unless the user explicitly allows disruption.

## Research Source Priority

For public research, Computer Use is an escalation route rather than the
default information source:

1. Discover candidate sources with the runtime's web search. On Hermes, prefer
   `web_search`; if its provider is unavailable, use `web-access`, a stable
   official API, RSS, GitHub API, or browser search and disclose the gap.
2. Read first-party pages through an official API, `curl`, or a static reader.
   Search snippets locate sources but do not prove claims.
3. Use Browser, `agent-browser`, Playwright, or CDP for JavaScript-rendered
   pages and structured interaction.
4. Use an authenticated Chrome route only when public/static sources cannot
   provide the requested evidence.
5. Use Computer Use for the user's current visible browser state, native apps,
   system UI, or a route mismatch that cannot be resolved from DOM/CDP state.

Do not let failure of one browser transport block public research. Record the
failed route, continue through official pages/APIs/static mirrors, and state
what could not be verified.

## Runtime Detection

- **Codex desktop:** Computer Use commonly exposes `get_app_state`; Chrome
  Extension and bundled Browser tools may also be present.
- **Hermes:** prefer built-in `web_search` and browser tools for public work.
  `agent-browser` is the deterministic CLI fallback. Hermes `computer_use`
  uses `cua-driver`; run `hermes computer-use status` or `doctor` before
  depending on it.
- A skill name or enabled toolset is not proof that its binary, provider,
  OAuth session, CDP endpoint, or macOS permission is ready. Verify the live
  route before reporting access.

## macOS Priority

For the user's Mac, prefer this order for visible Chrome pages:

1. **Computer Use for Google Chrome** when the user wants the agent to look at or operate the currently visible/real Chrome window. In Codex use `get_app_state`; in Hermes use `computer_use(action="capture", mode="som", app="Google Chrome")`. This works even when Chrome DevTools Protocol is not enabled, provided the runtime's desktop driver and permissions are healthy.
2. **Computer Use for authenticated Google/GSC/dashboard state** when the task depends on the user's real login, cookies, current profile, already-open tab, or a screenshot/user statement that the page is open. This includes Google Search Console / GSC, Google Analytics, Vercel dashboards, Gmail, account chooser disputes, and automation follow-ups where the user says they are already logged in.
3. **Chrome Extension / Chrome plugin tools** when tools such as tab listing, tab claiming, screenshots, DOM reads, or Playwright-like control are exposed and the task does not need the real visible Chrome login state, or after Computer Use confirms the intended Chrome profile/window is not available.
4. **Browser / in-app browser tools** for local app QA when the target URL is known and the user does not specifically need their real Chrome profile, cookies, extensions, or already-open tabs.
5. **Chrome DevTools Protocol** only when CDP tools are exposed and Chrome is listening on the expected debugging port, commonly `127.0.0.1:9222`. If this fails with `Failed to fetch browser webSocket URL`, explain that CDP is not enabled and try Computer Use or another route.
6. **Shell/curl/static inspection** only for non-visual checks such as HTTP status, sitemap, robots, metadata, build output, and generated HTML.

For generic public research where the user did not ask about the current
visible Chrome window, reverse that emphasis: start with web search and
first-party static/API sources, then Browser, and use Computer Use only as an
escalation.

## Authenticated Google / GSC Rule

For macOS tasks involving Google Search Console, GSC, Google account login state, or a user-visible Google dashboard:

1. Start with Computer Use:

   ```json
   {"app":"Google Chrome"}
   ```

2. Read the returned Chrome window title, URL, visible account, selected resource, and page text before opening new tabs or using extension/headless tools.
3. If Computer Use sees the intended logged-in page, treat that as the source of truth for login state.
4. If a Chrome Extension, Browser, web-access, or headless route says `account chooser`, `signed out`, `ChatGPT Atlas blocked`, empty shell, or login required while the user says Chrome is open/logged in, immediately switch to Computer Use for Google Chrome before reporting a login blocker.
5. Use extension/headless routes only as supplements after the real Chrome state is known, for example to read structured DOM, open extra tabs, or run static site checks.
6. For recurring automations such as Quick Image Kit GSC checks, if GSC cannot be read via extension/headless but Computer Use can see the logged-in Search Console page, continue the GSC check through Computer Use instead of notifying that GSC is unavailable.

## Linux / Remote Priority

For Linux, SSH, containers, or remote hosts, prefer non-GUI routes first:

1. Use `web-access` for internet search, page retrieval, scraping, and network-facing web interaction.
2. Use headless browser or project browser skills when available for local/remote app QA.
3. Use shell checks (`curl`, app logs, tests, static HTML) for status and metadata.
4. Use desktop Computer Use only if a graphical browser is actually available and the user asks for that surface.

## Failure Handling

Use this diagnosis language:

- `Chrome Extension connected` means the browser extension is present and connected to Codex, but the agent still needs matching callable tools in the current session.
- `Chrome Extension signed out` means only the extension-controlled profile appears signed out. On macOS, confirm real Google Chrome with Computer Use before concluding the user is signed out.
- `Chrome DevTools Protocol unavailable` means the debugging endpoint is not listening, usually because Chrome was not launched with `--remote-debugging-port=9222`.
- `Computer Use cgWindowNotFound` means Computer Use could not find a visible Chrome window to inspect. This is route-specific evidence only; it does not prove the Chrome process is absent, the user is signed out, or the target tab does not exist. On macOS, check whether Chrome is running and whether a visible window is available before concluding the task is blocked.
- `Hermes computer_use enabled` does not prove `cua-driver` is installed or has Accessibility and Screen Recording permission. Confirm with `hermes computer-use status` and `hermes computer-use doctor`.
- `Computer Use available` means the active runtime can inspect and operate app UI through accessibility/screenshot state, but it may be less precise than DOM/Playwright/CDP for console, network, and structured DOM assertions.

Do not stop after a single failure unless the user only asked for that route. Report route-specific failure and continue with the next viable route.

## Prompt Pattern

When a browser task starts, reason internally with:

```text
Need to inspect/control Chrome or a web page.
First choose the route by surface:
- macOS real Chrome/current tab: use Computer Use get_app_state first.
- GSC / Google Search Console / Google login / user says already open or logged in: use Computer Use for Google Chrome first; extension/headless signed-out state is not authoritative.
- Authenticated/profile-dependent Chrome tab that is not user-visible and not a Google/GSC login dispute: Chrome extension/plugin tools may be used, but switch to Computer Use on mismatch.
- Local app QA where real Chrome is not required: use Browser/in-app browser or headless browser.
- Linux/remote/non-GUI: use web-access/headless/curl before desktop assumptions.
- CDP only if DevTools tools are exposed and 127.0.0.1:9222 is listening.
- Hermes public research: web_search -> official API/curl/static reader -> browser/agent-browser -> authenticated Chrome -> cua-driver.
If the first route fails, name that route and try the next viable route before asking the user to fix setup.
```
