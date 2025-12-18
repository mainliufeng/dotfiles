# howdy

Linux 上的面部识别认证（PAM）。

## 安装

```sh
./setup.sh
```

Arch 说明：这里走 AUR，所以需要先安装 `yay` 或 `paru`。

## 配置 / 录入

### 1) 应用配置（执行脚本）

把本仓库里的 `howdy/config.ini` 覆盖到系统 howdy 配置位置（脚本会自动备份原配置）：

```sh
./apply-config.sh
```

需要调整摄像头设备（例如 `/dev/video2` 红外）就直接改 `howdy/config.ini` 里的 `device_path`，再重新执行一次脚本即可。

### 2) 录入 / 测试

```sh
sudo howdy add
./test.sh
```

#### `./test.sh` 里红圈是什么意思？

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

## 备份 / 回滚（修改 PAM 前先做）

建议顺序：先留后路（TTY）→ 先备份 `/etc/pam.d` → 再改 SDDM/PAM。

### 1) 手动备份（推荐，最稳）

```sh
sudo install -d -m 0700 /var/backups/howdy-dotfiles/pam.d
sudo cp -a /etc/pam.d "/var/backups/howdy-dotfiles/pam.d/manual.$(date +%Y%m%d_%H%M%S)"
```

### 2) 快速回滚：禁用 howdy（优先）

如果你已经被锁在登录界面外（SDDM/TTY 都进不去），请先切到 root TTY / SSH 会话再执行：

```sh
sudo ./howdy/pam-rollback.sh --disable --apply
```

### 3) 从快照恢复 `/etc/pam.d`

如果你之前运行过 `./howdy/enable-sddm.sh`（它会自动创建快照），就可以恢复到最新快照：

```sh
./howdy/enable-sddm.sh restore
```

## 启用 SDDM 登录（Hyprland + KDE SDDM）

目标：让 SDDM 登录界面在输入密码前尝试 howdy；失败时仍可用密码登录（不至于直接锁死）。

### 步骤 0：手动准备（务必做）

1) 先开一个 TTY（例如 `Ctrl+Alt+F3`）登录进去别关；万一 SDDM 登录坏了还能回滚。
2) 先做一次手动备份（见上面“备份 / 回滚”）。
3) 确认 howdy 已录入：`sudo howdy list -U $USER`

### 步骤 1：执行脚本（在这一步跑）

在本仓库根目录执行：

```sh
./howdy/enable-sddm.sh
```

脚本会：
- 在 `/etc/pam.d/sddm` 里加入 howdy 的 PAM 行（已做幂等处理）
- 在 `/var/backups/howdy-dotfiles/pam.d/<timestamp>/` 创建一份 `/etc/pam.d` 快照

### 步骤 2：重启 SDDM 生效（手动执行）

```sh
sudo systemctl restart sddm
```

### 回滚（手动执行）

如果 SDDM 登录异常，切到 TTY 后执行：

- 禁用 howdy 行（推荐先做）：`./howdy/enable-sddm.sh disable`
- 或从快照恢复：`./howdy/enable-sddm.sh restore`

## 常见问题

### 1) `./test.sh` 无法打开窗口（Wayland / Hyprland）

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

那就按下面 C/D 的方式在 root 下跑（避免“root 连不上显示”的问题）。`./test.sh` 已经把这些封装好了，优先用脚本。

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

### 2) SDDM 登录立刻失败（`ConfigParser` 报错）

如果你在日志里看到类似错误：

`ModuleNotFoundError: No module named 'ConfigParser'`

说明 howdy 的 `pam.py` 还是按 Python2 写法在跑，但你系统用的是 `pam_python3.so`。重新执行一次：

```sh
./howdy/enable-sddm.sh enable
```

脚本会自动给 `/lib/security/howdy/pam.py` 打补丁（并留 `.bak.<timestamp>` 备份）。
