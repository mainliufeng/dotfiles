# Yoga Pro 14s IAH7 / 82TK 键盘 stuck-repeat 适配

## 现象

内置键盘按键释放后，系统仍持续输入同一个字符；GUI 中也可能表现为持续触发同一个快捷键，例如一直切换窗口。Zen kernel 和 LTS kernel 都复现过，因此先按本机固件/EC/i8042 键盘控制器路径问题处理，而不是按单一 kernel flavor 回归处理。

当前机器信息：

- 型号：Lenovo Yoga Pro 14s IAH7 / 82TK
- BIOS：HMCN33WW，2022-07-22
- 内置键盘：`AT Translated Set 2 keyboard`
- 输入链路：`i8042` / `atkbd`

## 当前修复

在 `/etc/default/grub` 的 `GRUB_CMDLINE_LINUX_DEFAULT` 里追加：

```text
i8042.reset i8042.nomux atkbd.reset
```

然后重建 GRUB：

```bash
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

重启后用下面命令确认参数生效：

```bash
cat /proc/cmdline
```

应该能看到：

```text
i8042.reset i8042.nomux atkbd.reset
```

## 参数含义

- `i8042.reset`：启动时重置 i8042 键盘控制器，清理 BIOS/EC 留下的异常状态。
- `i8042.nomux`：禁用 i8042 multiplexing 检测，走更简单的控制器路径。
- `atkbd.reset`：初始化 `atkbd` 驱动时重置键盘设备。

这组参数是为了减少 press 事件到了但 release 事件丢失，导致 X11 一直 auto-repeat 的概率。

## 回滚

如果出现 Fn 键、特殊功能键、键盘背光、睡眠唤醒后的键盘行为异常，移除这三个参数后重建 GRUB 并重启。

## 复现取证

如果改完仍复现，运行：

```bash
~/watch-keyboard-events.sh
```

复现后停止记录，检查 `~/keyboard-debug/i8042-keyboard-*.log`。如果某个键只有 `pressed` 没有 `released`，问题在 kernel/i8042/固件层；如果 release 正常但 GUI/终端仍重复，继续查 X11/KDE 状态。
