# input-method

本机的中文输入栈。

| 文件 | 作用 |
|---|---|
| `setup-rime-ice.sh` | fcitx5 + Rime（rime-ice 方案）——**打字**输入法 |
| `setup-vinput.sh` | fcitx5-vinput（含二级精修）——**语音**输入 |
| `hotwords.txt` | 语音输入的热词表（英文技术词/专有名词），由 `setup-vinput.sh` 链接到 `~/.config/vinput/hotwords.txt` |

两者不冲突，可以同时装：Rime 负责键盘输入，vinput 是 fcitx5 的 **Module**（不是输入法），
靠右 Alt 热键触发，不需要切换输入法。

## 语音输入：为什么用 fork 而不是上游

Linux 上没有微信输入法 / 豆包输入法那种语音输入。开源里 `fcitx5-vinput` 已经做得很好，
但它的本地 ASR 只能**二选一**：

- 流式模型：边说边出字，但小模型在专有名词、中英混说上会出错
- 离线模型：整段转写更准，但松手后才出字

我们的 fork 加了**二级精修**，变成接力：说话时流式上屏，松手后用另一个更准的离线模型
对同一段音频重解码定稿。只多花 150–250 ms。

**关键坑（已写进脚本和文档）**：精修模型必须是**双语**的离线模型。
用 SenseVoice（中文倾向）会把英文词改坏——实测 `repo`→`RAIPPLE`、`prompt`→`PROMT`、
`push`→`布置`、`流式`→`流逝`。

## 安装

```bash
bash setup-vinput.sh
```

脚本会：检查依赖 → 克隆/更新 fork → 编译安装 → 下载两个模型并配置成 pass 1 / pass 2 →
链接热词表 → 起 systemd user 服务 → **重启 fcitx5**（这步最容易漏，不重启 addon 不生效）。

需要 sudo 的地方只有 `cmake --install`。

## 使用

| 按键 | 行为 |
|---|---|
| 右 Alt 短按 | 开始录音 / 再按停止 |
| 右 Alt 长按 | 按住说话，松开即停 |

必须有聚焦的文本输入框；不需要切换到"语音输入法"。

## 排错

```bash
# 看两遍解码的结果
journalctl --user -u vinput-daemon | grep -E 'pass 1|pass 2' | tail -4

# 开调试日志
mkdir -p ~/.config/systemd/user/vinput-daemon.service.d
printf '[Service]\nEnvironment=VINPUT_DEBUG=1\n' \
  > ~/.config/systemd/user/vinput-daemon.service.d/debug.conf
systemctl --user daemon-reload && systemctl --user restart vinput-daemon
```

热键没反应时，先确认 fcitx5 进程启动时间晚于 addon 安装时间：

```bash
ps -o pid,lstart -p $(pgrep -x fcitx5)
```

## 详细文档

完整的安装 / 配置 / 排错文档（带截图）在 fork 仓库里：

`apps/voice-input/docs/install-and-config-zh.md`
（GitHub: <https://github.com/mainliufeng/fcitx5-vinput/blob/main/docs/install-and-config-zh.md>）

上游项目：<https://github.com/xifan2333/fcitx5-vinput>（GPL-3.0）
