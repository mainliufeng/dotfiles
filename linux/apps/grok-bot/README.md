# Grok Bot 官方 Linux 更新器

当前采用**用户级官方原包**，不需要 sudo。系统里的 `grok-bot-desktop`
可能仍显示旧版本；应用菜单和 `~/.local/bin/grok-bot` 使用本更新器安装的版本。

## 使用

```sh
# 查看候选版本，不安装
~/dotfiles/linux/scripts/update-grok-bot --check

# 从 Grok Bot 菜单完全退出应用，然后更新
~/dotfiles/linux/scripts/update-grok-bot

# 更新后从应用菜单重新打开 Grok Bot
# 需要回退时先退出应用，再切回上一份程序
~/dotfiles/linux/scripts/update-grok-bot --rollback
```

也提供 `~/.local/bin/update-grok-bot` 便捷入口。脚本仅支持 Linux x86_64，
需要 Python 3.12+ 和 `ar`（Arch 的 binutils）；可选 desktop-file-utils。
依赖不自动安装，脚本不改变系统包、安全策略或代理。

## 来源与边界

- 从 AUR `grok-bot-bin` 的 PKGBUILD **只读取**版本、官方构建 ID 和对应 SHA256。
  **从不 source/执行 PKGBUILD**，不执行其托盘注入脚本。
- 安装包只能来自 `https://downloads.cursor.com/grokbot/stable/.../linux/x64/...deb`，
  重定向不允许换域名或降级 HTTP。每次重新获取此版本对应校验值，非固定旧 checksum。
- AUR 是版本线索及 checksum 来源，不是厂商签名；HTTPS 和 checksum 并不等同签名验证。
  AUR 也可能滞后，`--check` 输出的是候选版，不保证比官网更新。
- AUR 元数据结构变动时停止，而不是猜测地址或执行外部脚本。
- 官方有新版、AUR 尚未跟进时，可用明确的官方 URL 和该包对应 checksum：

```sh
update-grok-bot --version X.Y.Z --url 'https://downloads.cursor.com/grokbot/stable/构建ID/linux/x64/grok-bot_X.Y.Z_amd64.deb' --sha256 '该包的64位sha256'
```

## 安全和回退

1. 拒绝 root、错误架构、校验失败、包内版本不符、非 x86_64 ELF。
2. 更新前发现 Grok Bot 运行则停止，不强杀、不中断用户工作。
3. 仅安全解压 `opt/Grok Bot`；不执行 Debian 安装脚本，不安装 AppArmor，
   不添加 SUID，不修改系统 `/opt`、`/etc` 或系统包。
4. 备份 `~/.config/Grok Bot` 和旧启动器到私有的
   `~/.local/opt/grok-bot/backups/`，不删除/覆盖账号配置。
5. 下载、解压、版本验证都在临时目录完成；成功后保留版本目录，
   原子切换 `current`。启动器更新失败则恢复原指针及启动器。
6. `--rollback` 切回 `previous` 程序，不覆盖账号数据。新版若迁移了数据格式，
   旧版可能不兼容；不要盲目用旧数据覆盖新数据。备份可用于人工恢复。
7. 不自动启动、登录、购买或接受条款；完成更新不等于已验证账号/联网可用。
8. 已有版本目录不会被覆盖；旧版本和备份不自动清理。并发更新有文件锁。

首次脚本运行会采用此前用户级安装；后续版本切换才有 `previous` 可回退。
独立测试不使用真实账号数据：

```sh
python -m unittest discover -s ~/dotfiles/linux/apps/grok-bot/tests -v
```
