# DingTalk Wayland Screenshare

Linux DingTalk 8.1.0 still shows a black screen when sharing on KDE Wayland.
The working local fix is the community `LD_PRELOAD` hook:

<https://github.com/lzl200110/dingtalk-wayland-screenshare>

## Installed Files

- `bin/dingtalk-wayland-hook`: wrapper used by the app launcher.
- `lib/dingtalk-wayland-screenshare/libdingtalkhook.so`: built hook library.
- `applications/com.alibabainc.dingtalk.desktop`: per-user app launcher entry.

`link.sh` links these into:

- `~/.local/bin/dingtalk-wayland-hook`
- `~/.local/lib/dingtalk-wayland-screenshare/libdingtalkhook.so`
- `~/.local/share/applications/com.alibabainc.dingtalk.desktop`

## Rebuild Hook

```bash
git clone --recursive https://github.com/lzl200110/dingtalk-wayland-screenshare.git
cd dingtalk-wayland-screenshare
cmake -S . -B build -GNinja -DCMAKE_BUILD_TYPE=Release
cmake --build build
install -m 0755 build/libdingtalkhook.so ~/dotfiles/linux/apps/dingtalk/lib/dingtalk-wayland-screenshare/libdingtalkhook.so
~/dotfiles/linux/apps/dingtalk/link.sh
```

## Verify

Launch DingTalk from the application launcher or run:

```bash
dingtalk-wayland-hook
```

When screen sharing works, DingTalk shows a green sharing bar and the preview
contains the real desktop content instead of a black screen.
