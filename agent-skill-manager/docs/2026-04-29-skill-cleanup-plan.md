# Skill Cleanup Plan for GPT-5.5

日期：2026-04-29

目标：不改现有 skill 正文内容，先清理安装面、重复 skill、旧运行时副本和 runtime prompt，让 GPT-5.5 在更少干扰下工作。

状态：已按本文范围实施。本文同时作为本轮清理记录。

注意：本文是 2026-04-29 的历史快照。当前 skill 安装/审计执行源已经迁移到 TSV registry：

- 公共 registry: `~/dotfiles/agent-skill-manager/skill/assets/registries/public-skills.tsv`
- 私有 registry: `~/dotfiles-private/agent-skill-manager/assets/registries/private-skills.tsv`

文中的 “catalog” 和 `skill-catalog.md` 均指旧迁移阶段说法，不再代表当前执行源。

## 原则

- 不重写 `content-creator`、`knowledge`、`rcrai-*` 等已有 skill 内容。
- 优先减少默认可用 skill 数量，避免重复触发和旧副本抢规则。
- `agent-skill-manager` 的 TSV registry 是安装 source of truth。
- `dotfiles-private/agent-skill-manager/private_skills/` 是私有 skill source of truth。
- 旧运行时目录只在确认不再作为 source of truth 后清理。

## 需要删除的 Prompt

删除 runtime doc fragment 里的语言对齐 prompt：

```md
## Language Alignment Prompt
```

对应 source：

- `~/dotfiles/agent-skill-manager/skill/assets/agent-doc-fragments/base.md`

执行后需要重新渲染 / 同步：

- `~/.codex/AGENTS.md`
- `~/.claude/CLAUDE.md`
- `~/dotfiles/AGENTS.override.md`

说明：删除的是 runtime instruction prompt，不删除任何 skill。

## Superpowers 停装

目标：`superpowers` 不再安装到任何工具，观察不使用该 skill 时 GPT-5.5 的自然表现。

旧 catalog 条目：

```md
| superpowers | upstream bootstrap | codex, claude-code | special:superpowers | special flow |
```

计划：

1. 从旧 `~/dotfiles/agent-skill-manager/skill/assets/skill-catalog.md` 的 active table 中移除 `superpowers`。
2. 删除 `skill/assets/special-installs/superpowers.md` 和 `skill/assets/agent-doc-fragments/superpowers.md`，避免以后误恢复 bootstrap prompt。
3. 清理或停用 runtime 中已安装的 superpowers：
   - `~/.codex/superpowers/`
   - `~/.codex/skills/superpowers*` 如果存在
   - `~/.claude/skills/superpowers*` 如果存在
4. 重新同步 runtime docs，确保不会再注入 “run superpowers bootstrap” 这类启动提示。

验收：

- 当前 TSV registry 中没有 active `superpowers` 安装目标。
- Codex / Claude Code 的 runtime docs 不再要求 bootstrap superpowers。
- 新会话中不会自动触发 superpowers skill。

## content-research-writer 清理

核对结果：`content-research-writer` 不在当前 `agent-skill-manager` public registry，也不在 private registry；不属于当前 source of truth。

发现的旧副本 / 运行时副本：

- `~/dotfiles-private/.codex/skills/content-research-writer/`
- `~/dotfiles-private/.claude/skills/content-research-writer/`
- `~/.agentdev/skills/content-research-writer/`
- `~/.claude/skills/content-research-writer/`
- `~/.codex/skills_backup/content-research-writer/`

计划：

- 删除这些旧副本。
- 不把它迁入 `agent-skill-manager`。
- 以后写作调研默认使用：
  - `knowledge`：调研、选题、research 落盘
  - `content-creator`：成稿、平台适配、content_create 落盘

验收：

- `find` 不再能在 runtime / backup 目录里找到 `content-research-writer`。
- 当前 TSV registry 中没有该 skill。

## 删除 amap-jsapi-skill

当前 source：

- `~/dotfiles/agent-skill-manager/public_skills/amap-jsapi-skill/`

计划：

- 删除整个目录。
- 当前 catalog 没有登记该 skill，不需要从 active table 移除。

验收：

- `public_skills/amap-jsapi-skill/` 不存在。
- `git status` 显示该目录内 tracked 文件被删除。

## 合并本地 Arch Linux 桌面操作 Skill

当前分散 skill：

- `hyprland`
- `touchpad-recovery`
- `bluetooth-earbuds`

判断：这三者都属于本机 Arch Linux / Hyprland 桌面环境操作，不应该作为三个独立 skill 长期存在。

计划新建：

- `archlinux-desktop-ops`

覆盖范围：

- Hyprland workspace / window 操作
- 蓝牙耳机安装、配对、连接、音频路由切换
- 触摸板异常恢复
- 本仓库已有脚本入口说明

迁移内容：

- 从 `public_skills/hyprland/SKILL.md` 提取 Hyprland 操作说明。
- 从 `public_skills/bluetooth-earbuds/SKILL.md` 提取蓝牙与音频路由说明。
- 从 `public_skills/touchpad-recovery/SKILL.md` 提取触摸板排障说明。
- 移入脚本：
  - `public_skills/hyprland/scripts/*`
  - `public_skills/touchpad-recovery/scripts/rebind-touchpad.sh`

catalog 变更：

- 删除 active row：
  - `hyprland`
  - `touchpad-recovery`
- 不新增 `bluetooth-earbuds` 的独立 row。
- 新增：

```md
| archlinux-desktop-ops | local repo | codex | default | local Arch Linux / Hyprland desktop operations |
```

删除旧目录：

- `public_skills/hyprland/`
- `public_skills/touchpad-recovery/`
- `public_skills/bluetooth-earbuds/`

验收：

- catalog 只保留 `archlinux-desktop-ops`。
- 旧三个 skill 不再存在。
- 新 skill 中能找到原有脚本和主要操作入口。

## rcrai 保留

保留当前私有 source of truth：

- `~/dotfiles-private/agent-skill-manager/private_skills/rcrai/`
- `~/dotfiles-private/agent-skill-manager/private_skills/rcrai-design/`
- `~/dotfiles-private/agent-skill-manager/private_skills/rcrai-impl/`
- `~/dotfiles-private/agent-skill-manager/private_skills/rcrai-review/`

尤其保留：

- `private_skills/rcrai/assets/*`
- `private_skills/rcrai/scripts/feature_flow.py`

原因：模板、组织规则、平台基线、测试 pattern 都在 `rcrai/assets` 里。

注意：

- 不删除 `rcrai`。
- 不删除 `rcrai/assets`。
- 如果发现旧 runtime 单文件 `rcrai` 副本，只做重复性检查，不在本轮直接删。

## 浏览器访问类 Skill 优先级

目标：明确优先用哪个，减少 `agent-browser`、`web-access`、`webapp-testing`、gstack browse、Chrome DevTools MCP、Playwright、Computer Use 类 skill 互相抢规则。

### 默认优先级

0. **`chrome-access-routing`**
   - 先判断目标表面：macOS 真实 Chrome / 已打开标签页 / Chrome 插件状态 / localhost app / 生产 URL / Linux headless / 登录态页面。
   - 不要因为 Chrome DevTools MCP 端口失败就放弃；优先尝试下一条可行通道。

1. **macOS 真实 Chrome：Computer Use / Chrome 插件通道**
   - 用户明确让 agent 看当前 Chrome、已打开页面、插件是否 connected、真实登录态或桌面状态时，优先用 Computer Use 的 `Google Chrome` app 状态。
   - 如果当前 session 暴露了 Chrome Extension tab-control 工具，再用插件通道。
   - Chrome DevTools MCP 只在 `127.0.0.1:9222` 已监听并且确实需要 DevTools/console/network 时使用。

2. **gstack `browse` / `qa` / `qa-only`**
   - 当任务不需要用户真实 Chrome 会话或当前可见窗口时，用于网页浏览、网页测试、截图、本地 web app dogfood、视觉 QA。

3. **gstack `design-review` / `benchmark` / `canary`**
   - 用于更专门的前端设计 QA、性能回归、部署后巡检。

4. **`web-access`**
   - Linux / 远程 / 非 GUI 环境下优先用于联网读取、搜索、页面抓取和网络交互。
   - 也用于中文平台、反爬页面、社交媒体、动态渲染页面，或 gstack browse 无法拿到目标内容时。

5. **`webapp-testing`**
   - 建议停用或不再安装。
   - 原因：本地 web app 浏览、截图和 QA 已由 gstack `browse` / `qa` 覆盖；继续保留会增加触发歧义。

6. **`agent-browser`**
   - 建议停用或不再安装。
   - 原因：它和 chrome-access-routing / gstack browse / web-access 重叠。

7. **Chrome DevTools MCP 直接工具**
   - 不作为默认浏览器访问方式。
   - 只有在端口可用、gstack / web-access / Computer Use 都不适合，且任务明确需要 DevTools 层能力时临时使用。

### 建议保留

- `chrome-access-routing`
- gstack browse/qa 系列
- `web-access`

### 建议停用

- `webapp-testing`
- `agent-browser`

## 不在本轮做

- 不改 `content-creator` 正文。
- 不改 `knowledge` 正文。
- 不改 `rcrai-*` 正文。
- 不改 OpenAI / GPT-5.5 相关 prompt。
- 不切换 Codex 默认 model，除非单独确认。
- 不删除 `rcrai` 或 `rcrai/assets`。

## 建议执行顺序

1. 删除语言对齐 prompt，并同步 runtime docs。
2. 从 catalog 停装 `superpowers`，清理 runtime bootstrap。
3. 删除 `content-research-writer` 旧副本。
4. 删除 `amap-jsapi-skill`。
5. 合并 `hyprland`、`touchpad-recovery`、`bluetooth-earbuds` 为 `archlinux-desktop-ops`。
6. 按浏览器访问优先级停用 `webapp-testing` 和 `agent-browser`。
7. 做一次 catalog/runtime audit，确认没有 stale skill。
