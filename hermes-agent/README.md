# Hermes Agent

`setup.sh` installs or reuses Hermes Agent and then prepares the minimum local
research stack:

- `web.search_backend=ddgs` for keyless public-web discovery;
- Hermes browser tools backed by the separately managed `agent-browser` module;
- `hermes-research-browser`, an explicit persistent profile isolated from the
  user's daily Chrome profile;
- `cua-driver` for native desktop Computer Use on macOS, Windows, and Linux.

Page extraction deliberately stays layered instead of pretending DDGS can
extract bodies: prefer first-party APIs or `curl`, then Jina/`web-access`, then
Hermes browser automation for dynamic pages. Use a real Chrome profile only
when the task actually requires authenticated state.

The default research browser stores its profile under
`~/.hermes/browser-profiles/research`. It does not copy or export cookies from
the user's daily Chrome. Authenticated daily-Chrome access remains an explicit
`web-access`/CDP route after the user enables Chrome remote debugging.

## macOS permission check

The driver installation is automatic, but macOS Accessibility and Screen
Recording grants remain a user decision:

```bash
hermes computer-use permissions status
hermes computer-use permissions grant
hermes computer-use doctor
```

Grant permissions to `CuaDriver.app` (`com.trycua.driver`), not Terminal or
Hermes. The setup script never clicks permission dialogs or exports browser
cookies.

## Smoke checks

```bash
hermes tools list --platform cli
hermes config get web.search_backend
hermes computer-use status
agent-browser --session hermes-research-smoke open https://example.com
agent-browser --session hermes-research-smoke snapshot -c -d 2
agent-browser --session hermes-research-smoke close
hermes-research-browser --session hermes-profile-smoke open https://example.com
hermes-research-browser --session hermes-profile-smoke close
```
