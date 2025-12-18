# howdy

Linux 上的面部识别认证（PAM）。

## 安装

```sh
./setup.sh
```

Arch 说明：这里走 AUR，所以需要先安装 `yay` 或 `paru`。

## 配置 / 录入

### 1) 打开配置文件（使用 nvim）

howdy 默认会尝试用 `nano` 打开配置；如果你没有装 nano，可以用 nvim：

```sh
sudo EDITOR=nvim howdy config
```

它打开的是 howdy 的配置文件：`/usr/lib/security/howdy/config.ini`。

### 2) 必配项：设置摄像头设备

先找出摄像头对应的 `/dev/video*`：

```sh
v4l2-ctl --list-devices
ls -l /dev/video*
```

然后在 `config.ini` 的 `[video]` 段把 `device_path` 改成你的摄像头（示例）：

```ini
device_path = /dev/video0
```

本仓库也提供了一个“按你这台机器生成的参考配置”（Integrated RGB Camera）：`howdy/config.ini.liufeng`。

如果你想直接套用它（会覆盖系统配置，建议先备份）：

```sh
sudo cp -a /usr/lib/security/howdy/config.ini /usr/lib/security/howdy/config.ini.bak.$(date +%Y%m%d_%H%M%S)
sudo cp -a ./config.ini.liufeng /usr/lib/security/howdy/config.ini
```

关于 `/dev/video2`：很多笔记本会同时暴露 RGB/IR 等多个节点。如果 `/dev/video2` 是红外画面，你可以在 `config.ini` 里把 `device_path` 改成 `/dev/video2` 试用哪个更稳定。

你也可以先快速验证摄像头能否出画面（可选，但推荐）：

```sh
mpv av://v4l2:/dev/video0
```

### 3) 常用参数（按需调整）

- `[video].certainty`：匹配阈值；越低越严格（更安全但可能更容易失败），不建议调到 5 以上。
- `[video].timeout`：识别超时时间（秒）；镜头启动慢可适当加大。
- `[video].recording_plugin`：默认 `opencv`；如果遇到灰度/画面异常可尝试 `ffmpeg`。
- `[video].force_mjpeg`：如果你的摄像头输出是 `MJPG`，且遇到黑屏/花屏，可改成 `true` 试试。
- `[core].ignore_ssh`：默认 `true`，建议保留（远程 shell 禁用 howdy）。
- `[snapshots].capture_*`：登录成功/失败都抓拍留档；不需要可改为 `false`。

### 4) 录入 / 测试

```sh
sudo EDITOR=nvim howdy config
sudo howdy add
sudo howdy test
```

#### `sudo howdy test` 里红圈是什么意思？

在 howdy `2.6.1` 里，`howdy test` 主要用于检查“摄像头画面 + 人脸检测”是否工作：

- 画面中出现红色圆圈/红框：表示检测到人脸（这是正常现象）
- 它**不会**在这个窗口里显示“认证通过/失败”的绿圈之类结果

#### 一键测试脚本（带 `-U`，自动处理 Wayland/XWayland）

本目录提供了一个封装脚本：`./test.sh`，默认会选择 Wayland（优先）或 XWayland，并自动把 `-U` 指向当前登录用户。

```sh
./test.sh
./test.sh -U liufeng
```

#### `sudo howdy add` 里的 “label” 填什么？

`label` 只是“这次录入的人脸模型的名字/备注”，方便你以后区分多个模型（比如不同光线/不同角度/戴眼镜 vs 不戴眼镜）。

你可以直接回车用默认的 `Initial model`，或者填一个更具体的名字，例如：

- `default`
- `home-day`
- `glasses`
- `desk`

建议只用英文/数字/短横线，长度不超过 24 个字符。

## 安全提示（PAM）

在 `/etc/pam.d/*` 里启用 howdy 时务必谨慎：配置错误可能导致你无法登录（lock you out）。
测试期间请务必保留另一条可用的登录方式（例如 root TTY / SSH）。

## 回滚（如果被锁在门外）

本仓库提供一个“急救”回滚脚本：它会把 PAM 配置里与 howdy 相关的行注释掉，并在修改前把 `/etc/pam.d` 备份到 `/var/backups/howdy-dotfiles/pam.d/` 下的一个时间戳目录。

在 root TTY / SSH 会话中执行：

```sh
sudo ./pam-rollback.sh --disable --apply
```

如果你之前已经用该脚本创建过快照，也可以从“最新的快照”恢复 `/etc/pam.d`：

```sh
sudo ./pam-rollback.sh --restore --apply
```

## 常见问题

### 1) `sudo howdy test` 无法打开窗口（Wayland / Hyprland）

现象通常类似：

- `qt.qpa.xcb: could not connect to display`
- `Authorization required, but no authorization protocol specified`
- `Could not load the Qt platform plugin "xcb"...`
- 提示缺少 `xcb-cursor0` / `libxcb-cursor0`

处理思路：这是“GUI 显示权限 / Qt 依赖”问题，不是 howdy 配置文件写错。

**A. 先装齐 Qt xcb 依赖**

- Arch：`sudo pacman -S --needed xcb-util-cursor`
- Debian/Ubuntu：`sudo apt-get install -y libxcb-cursor0`

**B. 说明：有些发行版/版本要求 `howdy test` 必须 root**

如果你运行 `howdy test` 提示必须使用 root：

```
Please run this command as root:
    sudo howdy test
```

那就按下面 C/D 的方式在 root 下跑（避免“root 连不上显示”的问题）。

**C. 如果你必须用 sudo 打开窗口（XWayland）**

先临时允许 root 连接到你的 XWayland 显示，再运行命令，最后撤销授权：

```sh
xhost +SI:localuser:root
sudo --preserve-env=DISPLAY howdy test
xhost -SI:localuser:root
```

**D. Wayland（推荐：强制 Qt 用 Wayland 后端，避开 xcb）**

在 Wayland 桌面下，如果 `sudo howdy test` 老是走 xcb 并报 `could not connect to display`，可以强制 Qt 用 Wayland：

```sh
sudo --preserve-env=WAYLAND_DISPLAY,XDG_RUNTIME_DIR env QT_QPA_PLATFORM=wayland howdy test
```
