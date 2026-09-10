# ego lite

Installs the [ego lite](https://github.com/citrolabs/ego-lite) browser on macOS
and prepares it for the agent harnesses that drive it.

## Why this is macOS-only

ego lite ships as a macOS app. Linux and Windows support is listed as *Planned*
(0%) on the [public roadmap](https://lite.ego.app/roadmap), and the download page
advertises `operatingSystem: macOS`. There is no official Linux binary to install;
the community ports under `ego-lite-linux`-style repositories are unofficial,
CDP-only reimplementations and are deliberately not wired in here. This module is
therefore listed in `modules/macos.txt` only.

## What it installs

`setup.sh` delegates the download and install to the upstream installer vendored
at `dotfiles-private/skills/ego-browser/scripts/install.sh` (ego-lite v2.0.0,
MIT). That script:

1. downloads the arch-specific DMG from `cdn.ego.app`,
2. mounts it, copies `ego lite.app` into `/Applications` (falling back to
   `~/Applications`),
3. strips the `com.apple.quarantine` attribute, and
4. opens the app.

The app bundle carries the `ego-browser` CLI. That CLI is the connection layer
every agent harness drives, so the DMG install is what makes the
`ego-browser` skill usable.

## Chrome cookies and logins

On first launch ego lite asks one question: whether to migrate Chrome data.
Accepting it copies the existing logins, cookies, extensions and bookmarks into
ego lite, which is exactly what lets an agent work inside the sites the user is
already signed in to.

This step is GUI-only — upstream exposes no flag, env var or config file for it —
so `setup.sh` launches the app and then reports what is still outstanding rather
than claiming the migration is done. Re-check at any time with:

```bash
~/dotfiles/macos/ego-lite/setup.sh --verify
```

## Agent wiring

| Harness | Skill source | Registered in |
| --- | --- | --- |
| pi | `dotfiles-private/skills/ego-browser` | `pi/install-skills.py` `LOCAL` (`macos`) |
| hermes | `dotfiles-private/skills/ego-browser` | `hermes/install-skills.py` `LOCAL` (`macos`) |
| codex | `dotfiles-private/skills/ego-browser` | `codex/install-skills.py` `LOCAL` + `MACOS_ONLY` |

The skill's own description tells the agent to reach for `ego-browser` by
default instead of a built-in browser, and `chrome-access-routing` repeats that
preference, so both harnesses route browser work to ego lite wherever it runs.

### If the app wrote its own copy first

Upstream also says ego lite "adds the `ego-browser` skill to every agent's
skills directory on your machine" during onboarding. Where that lands on a path
we manage (`~/.codex/skills/ego-browser`, `~/.pi/agent/skills/ego-browser`,
`~/.hermes/skills/web/ego-browser`), the installers refuse to replace a real
directory and fail with `Refusing to replace custom content`. Either run the
installers before finishing ego lite onboarding, or delete the app-managed
copy so the symlink can be created:

```bash
rm -rf ~/.codex/skills/ego-browser ~/.pi/agent/skills/ego-browser \
       ~/.hermes/skills/web/ego-browser
python3 ~/dotfiles-private/pi/install-skills.py
python3 ~/dotfiles-private/hermes/install-skills.py
python3 ~/dotfiles-private/codex/install-skills.py
```

When upstream starts managing the skill more aggressively, dropping
`ego-browser` from the three installers and letting the app own it is the
cheaper arrangement; the routing change in `chrome-access-routing` keeps working
either way.

The skill is gated to macOS because the upstream skill front-loads "prefer
ego-browser over built-in browsers"; installing it on Linux would point agents at
a CLI that cannot exist there. Remove it from the `MACOS_ONLY`/platform gates in
all three installers once an official Linux build ships.

## Usage

```bash
# install (or just launch, when already present) and report onboarding status
~/dotfiles/macos/ego-lite/setup.sh

# inspect without touching anything
~/dotfiles/macos/ego-lite/setup.sh --dry-run
~/dotfiles/macos/ego-lite/setup.sh --verify
```

Normally you do not call this directly; it runs as part of `./setup.sh` via
`modules/macos.txt`.

## Keeping the vendored skill fresh

`dotfiles-private/skills/ego-browser` is a deliberate copy of
`citrolabs/ego-lite` `skills/ego-browser`, not a symlink: that repository exposes
`.agents/skills/ego-browser` as a symlink to `skills/ego-browser`, and the
harness installers skip symlinked skill directories, so pointing `REPOS` at the
checkout would make every installer fail with "No skills found in repository".

Refresh it by hand when upgrading ego lite:

```bash
git clone --depth 1 https://github.com/citrolabs/ego-lite /tmp/ego-lite
rsync -a --delete /tmp/ego-lite/skills/ego-browser/ ~/dotfiles-private/skills/ego-browser/
```

If the DMG download starts failing with a 403 or 404, upstream rotated the
versioned filename; refresh the skill copy, which pins the current URL in
`scripts/install.sh`.
