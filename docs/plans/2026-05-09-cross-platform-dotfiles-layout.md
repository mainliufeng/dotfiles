# Cross-Platform Dotfiles Layout

## 背景

这个 dotfiles repo 现在主要服务 Arch Linux 笔记本，里面混合了三类内容：

- 通用开发环境：`zsh`、`git`、`nvim`、`go`、`python`、`codex`、`claude-code`、`zellij`、`ghostty` 等。
- Linux/Arch 桌面环境：`hyprland`、`wayland`、`xorg`、`awesome`、`rofi`、`mako`、`pacman`、`libinput`、`lightdm`、`howdy` 等。
- 机器或发行版专用修复：`yoga-pro-14s`、`resolv`、`docker` systemd override、`timesyncd` 等。

目标是让 macOS 和 Linux 两台笔记本使用同一个顶层入口，但目录边界更清楚：

- repo 外层只放跨平台通用模块。
- `linux/` 放 Linux 专用模块。
- `macos/` 放 macOS 专用模块。
- 顶层 `setup.sh` / `link.sh` 在两台机器上命令一致，自动选择当前平台。

## 目标结构

```text
dotfiles/
  link.sh
  setup.sh
  README.md

  zsh/
  git/
  nvim/
  go/
  python/
  codex/
  claude-code/
  opencode/
  zellij/
  ghostty/
  kitty/
  fonts/
  scripts/
  agent-skill-manager/

  linux/
    setup.sh
    link.sh
    arch/
      setup.sh
      link.sh
      pacman/
      1_dev/
    desktop/
      hyprland/
      wayland/
      xorg/
      awesome/
      rofi/
      mako/
      kde/
      gnome/
      lightdm/
      libinput/
      swww/
    services/
      docker/
      redis/
      timesyncd/
      resolv/
      openvpn/
    hardware/
      howdy/
      yoga-pro-14s/
      light/
    apps/
      clash/
      dingtalk/
      chrome/
      antigravity/
      alma/
      confirmo/

  macos/
    setup.sh
    link.sh
    Brewfile
    defaults.sh
    apps/
    scripts/
```

外层目录的含义是“这份配置应该尽量同时能在 Linux 和 macOS 上工作”。如果某个模块需要平台判断，优先在模块内部处理；如果它本质上只属于一个平台，就移动到对应平台目录。

## 顶层入口

顶层入口在两台机器上保持一致：

```bash
./setup.sh
./link.sh
```

推荐支持这些参数：

```bash
./setup.sh                 # common setup + current platform setup
./setup.sh --common-only
./setup.sh --platform-only
./setup.sh --platform linux
./setup.sh --platform macos
./setup.sh --dry-run

./link.sh                  # common link + current platform link
./link.sh --common-only
./link.sh --platform-only
./link.sh --platform linux
./link.sh --platform macos
./link.sh --dry-run
```

平台检测：

```bash
case "$(uname -s)" in
  Darwin) platform="macos" ;;
  Linux)  platform="linux" ;;
  *)      error ;;
esac
```

顶层 `link.sh` 不再扫描所有子目录，而是读取明确的模块列表。这样可以避免 macOS 上误跑 `pacman/link.sh`、`docker/link.sh`、`hyprland/link.sh` 之类脚本。

## 模块清单

建议新增两个清单文件，让入口脚本简单可靠：

```text
modules/common.txt
modules/linux.txt
modules/macos.txt
```

示例：

```text
# modules/common.txt
zsh
git
nvim
go
python
codex
claude-code
opencode
zellij
ghostty
kitty
fonts
agent-skill-manager
```

```text
# modules/linux.txt
linux/arch
linux/desktop/hyprland
linux/desktop/wayland
linux/desktop/xorg
linux/desktop/awesome
linux/desktop/rofi
linux/desktop/mako
linux/services/docker
linux/services/redis
linux/hardware/howdy
linux/apps/clash
linux/apps/dingtalk
```

```text
# modules/macos.txt
macos
```

`link.sh` 的行为：

- 先跑 `modules/common.txt` 里的 `<module>/link.sh`。
- 再跑当前平台清单里的 `<module>/link.sh`。
- 模块没有 `link.sh` 时跳过并打印 `[skip]`。
- 任一模块失败时停止，除非显式传 `--keep-going`。

`setup.sh` 的行为同理，只是调用 `<module>/setup.sh`。

## macOS 目录职责

`macos/setup.sh` 负责 macOS 机器初始化：

- 检查 Homebrew，不自动安装 Homebrew，只给出提示。
- 执行 `brew bundle --file "$DOTFILES_HOME/macos/Brewfile"`。
- 安装 CLI：`git`、`gh`、`jq`、`ripgrep`、`fzf`、`neovim`、`go`、`pyenv`、`node`、`pnpm`、`bun`、`zellij`。
- 安装 shell 相关包：`zplug`、`powerlevel10k`。
- 安装终端和字体 cask：`ghostty`、`kitty`、Hack Nerd Font 或等价字体。

`macos/link.sh` 只做 macOS 专用链接和配置：

- 链接 macOS 专用脚本到 `~/.local/bin` 或 Homebrew path。
- 可选执行 `defaults.sh`，但默认应是提示式或需要显式参数，例如 `./macos/defaults.sh --apply`。
- 不处理 Linux 桌面配置。

`macos/Brewfile` 是 macOS 软件清单的 source of truth。

## Linux 目录职责

`linux/setup.sh` 是 Linux 平台入口，继续可以偏 Arch，但要把发行版边界写清楚：

- 如果检测到 `pacman`，调用 `linux/arch/setup.sh`。
- 如果不是 Arch，先只运行通用 Linux 可用的部分，或者直接提示 unsupported。

`linux/arch/` 放 Arch 包管理相关内容：

- 旧的 `pacman/`
- 旧的 `1_dev/`
- Arch 专用 package backup/restore

`linux/desktop/` 放 Linux 桌面环境：

- `hyprland`
- `wayland`
- `xorg`
- `awesome`
- `rofi`
- `mako`
- `kde`
- `gnome`
- `lightdm`
- `swww`

`linux/services/` 放 systemd 或 Linux 服务：

- `docker`
- `redis`
- `timesyncd`
- `resolv`
- `openvpn`

`linux/hardware/` 放硬件和本机修复：

- `howdy`
- `yoga-pro-14s`
- `libinput`
- `light`

## 通用模块需要的改造

### zsh

`zsh/.zshrc` 要成为跨平台配置：

- 所有 `source` 都加 `[[ -f ... ]]` 判断。
- `/home/liufeng` 改为 `$HOME`。
- Powerlevel10k 路径按平台探测：
  - Linux: `/usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme`
  - macOS Homebrew: `/opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme`
  - Intel macOS Homebrew: `/usr/local/share/powerlevel10k/powerlevel10k.zsh-theme`
- Android SDK 按平台设置：
  - Linux: `/opt/android-sdk`
  - macOS: `$HOME/Library/Android/sdk`
- `PRIVATE_DOTFILES_HOME` 不存在时静默跳过。

### codex

`codex/config.toml` 里写死的 `/home/liufeng` 应拆出去：

- repo 里保留 `codex/config.common.toml`。
- `codex/link.sh` 根据当前 `$HOME` 生成或合并 `~/.codex/config.toml`。
- 机器专用的 trusted projects 放 `~/.codex/config.local.toml` 或单独模板，不要求两台机器完全一致。

### claude-code

`claude-code/settings.json.example` 不要写死 `/home/liufeng`：

- 使用 `$HOME` 可展开的 shell command，例如 `bash "$HOME/.claude/hooks/notify-complete.sh"`。
- `notify-complete.sh` 增加 macOS 通知：

```bash
osascript -e 'display notification "..." with title "Claude Code"'
```

### scripts/start-chrome-remote

增加 macOS Chrome 检测：

```bash
/Applications/Google Chrome.app/Contents/MacOS/Google Chrome
/Applications/Chromium.app/Contents/MacOS/Chromium
```

默认 profile 目录可以继续用 `$HOME/.cache/chrome-devtools`，也可以在 macOS 下改成：

```bash
$HOME/Library/Application Support/chrome-devtools-profile
```

### git

当前 `git/link.sh` 依赖 `git/.gitconfig`，但仓库内没有这个文件。需要二选一：

- 新增通用 `git/.gitconfig`。
- 或让 `git/link.sh` 在文件不存在时跳过，并提示使用本机私有 gitconfig。

## 迁移顺序

### 第一阶段：入口安全化

1. 新增 `modules/common.txt`、`modules/linux.txt`、`modules/macos.txt`。
2. 改造顶层 `link.sh`，不再无条件扫描所有目录。
3. 新增顶层 `setup.sh`，行为与 `link.sh` 对齐。
4. 先不移动目录，只让清单引用旧路径。

这一阶段完成后，macOS 上可以安全运行：

```bash
./link.sh --common-only
```

### 第二阶段：macOS 最小可用

1. 新增 `macos/Brewfile`。
2. 新增 `macos/setup.sh`。
3. 新增 `macos/link.sh`。
4. 修复 `zsh/.zshrc` 的平台路径。
5. 修复 `claude-code` 通知和 settings 示例。
6. 修复 `scripts/start-chrome-remote`。

这一阶段完成后，macOS 上可以运行：

```bash
./setup.sh
./link.sh
```

### 第三阶段：目录迁移

按风险从低到高移动目录：

1. 纯 Linux 桌面配置：`hyprland`、`wayland`、`xorg`、`awesome`、`rofi`、`mako`。
2. Arch 包管理：`pacman`、`1_dev`。
3. systemd/Linux 服务：`docker`、`redis`、`timesyncd`、`resolv`、`openvpn`。
4. 硬件和机器专用：`howdy`、`yoga-pro-14s`、`libinput`、`light`。
5. Linux 桌面 app：`clash`、`dingtalk`、`chrome`、`antigravity`、`alma`、`confirmo`。

移动时每个模块都要同步更新：

- 模块内部 `~/dotfiles/<old-path>` 引用。
- `modules/linux.txt`。
- README 或相关文档。
- 脚本中的相对路径。

### 第四阶段：清理旧入口

1. 删除旧的隐式全量行为。
2. README 明确：
   - macOS: `./setup.sh && ./link.sh`
   - Arch Linux: `./setup.sh && ./link.sh`
   - 只链接通用配置: `./link.sh --common-only`
3. 给危险模块加平台保护，例如 `pacman/link.sh` 检测不到 `pacman` 时直接退出。

## 保留兼容的策略

如果担心一次移动目录导致旧脚本失效，可以短期保留兼容 wrapper：

```text
hyprland/link.sh -> ../linux/desktop/hyprland/link.sh
pacman/link.sh   -> ../linux/arch/pacman/link.sh
```

但这只作为过渡。最终 repo 应该让目录结构表达平台边界，而不是靠 README 记忆。

## 验收标准

macOS：

- `./link.sh --dry-run` 不出现 `pacman`、`yay`、`systemctl`、`/etc/pacman.d`、`hyprland`。
- `./setup.sh --dry-run` 显示 Homebrew/Brewfile 路径。
- 新 shell 打开后没有 `/home/liufeng` 相关报错。
- `start-chrome-remote` 能找到 Chrome 或给出清晰提示。
- Claude Code hook 能触发 macOS 通知。

Linux/Arch：

- `./link.sh --dry-run` 包含 common + Linux modules。
- `./setup.sh --dry-run` 仍能覆盖原有 Arch 开发环境安装路径。
- Hyprland、Wayland、Xorg、pacman 相关配置仍只在 Linux 路径执行。
- 旧有脚本路径迁移后没有断链。

## 推荐最终命令

日常使用只记这两个：

```bash
./setup.sh
./link.sh
```

需要精细控制时：

```bash
./link.sh --common-only
./link.sh --platform-only
./setup.sh --platform macos
./setup.sh --platform linux
```
