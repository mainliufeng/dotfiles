# Cross-platform Skill Catalog Review

Date: 2026-05-10

## 背景

当前 `agent-skill-manager` 的 skill source of truth 分成两层：

- 公共 catalog: `~/dotfiles/agent-skill-manager/skill/assets/skill-catalog.md`
- 私有 overlay: `~/dotfiles-private/agent-skill-manager/assets/private-skill-catalog.md`

现在这台机器已经迁到 macOS + Codex App，且 dotfiles 也开始按 `macos/`、`linux/`、通用目录拆分。现有 skill catalog 里有一部分仍然假设 Arch Linux / Hyprland，或者重复了 Codex App 现在已经内置的能力，需要整理成 macOS 和 Arch Linux 都能用的形态。

本设计只规划改造，不直接执行安装。

## 当前观察

### 运行时实际安装状态

当前运行时目录里主要只安装了 manager skill：

- `~/.codex/skills/agent-skill-manager -> ~/dotfiles/agent-skill-manager/skill`
- `~/.claude/skills/agent-skill-manager -> ~/dotfiles/agent-skill-manager/skill`
- `~/.hermes/skills/meta/agent-skill-manager -> ~/dotfiles/agent-skill-manager/skill`

`~/.codex/skills/.system/` 里还有 Codex App 系统 skill：

- `imagegen`
- `openai-docs`
- `plugin-creator`
- `skill-creator`
- `skill-installer`

当前 catalog 中的大多数 skill 还只是“应安装清单”，不是运行时已安装状态。

### Codex App 内置插件能力

本机 Codex App 已缓存并启用 OpenAI primary runtime 插件：

- `documents` plugin
  - skill: `documents`
  - 覆盖 `.docx` 创建、编辑、redline、comment、render-and-verify workflow
- `spreadsheets` plugin
  - skill: `spreadsheets`
  - 覆盖 `.xlsx/.xls/.csv/.tsv`
- `presentations` plugin
  - skill: `presentations`
  - 覆盖 `.ppt/.pptx`

没有看到独立的内置 `pdf` skill/plugin。PDF 需求需要后续确认是：

- 由 `documents` skill 的渲染/导出 PDF 能力覆盖一部分；
- 还是继续保留 catalog 里的 `pdf` skill；
- 或者迁移到更明确的 PDF 处理工具 skill。

### 明显不再适合默认安装的 skill

`archlinux-desktop-ops` 的内容硬编码了：

- Arch Linux
- Hyprland
- bluetoothctl / pactl / libinput / journalctl / hyprctl
- `~/dotfiles/linux/desktop/hyprland/...`

它不应该在 macOS Codex App 环境默认安装或默认触发。

## 目标

1. 同一套 catalog 在 macOS 和 Arch Linux 上都可用。
2. 平台专用 skill 不能在错误平台默认触发。
3. Codex App 已内置的文档类能力不重复安装过时 skill。
4. 私有 skill `mainliufeng-local-env` 保留，但改成能描述 macOS/Arch Linux 双平台路径和边界。
5. `agent-skill-manager` 继续作为 source of truth，不直接把运行时目录当源头。

## 非目标

- 不在本阶段重写所有 skill 正文。
- 不在本阶段执行完整安装同步。
- 不删除已有 skill 源码，除非 catalog 明确降级后再单独清理。
- 不把私有 skill 移到公共仓库。

## 设计原则

### Catalog 必须表达平台条件

当前 catalog 只有：

```text
skill | source | targets | mode | status
```

这不足以表达 “Codex 目标存在，但仅 Arch Linux 安装”。建议扩展为：

```text
skill | source | targets | platforms | mode | status
```

`platforms` 建议取值：

- `all`
- `macos`
- `archlinux`
- `runtime-builtin`

如果暂时不想改表结构，也可以先把平台约束写进 `status`，但长期建议加列。

### 安装器必须按平台过滤

manager skill 后续安装时应先解析：

- 当前 OS: `Darwin` / `Linux`
- Arch Linux: 通过 `/etc/os-release` 确认 `ID=arch` 或 `ID_LIKE` 包含 `arch`
- 可用运行时: Codex / Claude Code / Hermes
- Codex App 内置插件是否已启用

不匹配平台的 skill 应显示为 `skipped: platform mismatch`，不是安装失败。

### 内置插件优先于外部 skill

对于 Codex App 已提供的 OpenAI primary runtime 插件：

- `documents`
- `spreadsheets`
- `presentations`

catalog 中不应再建议安装同类 GitHub skill，除非该 skill 提供内置插件没有的明确补充能力。

## Public Catalog 建议调整

### archlinux-desktop-ops

现状：

```text
archlinux-desktop-ops | local repo | codex | default | local Arch Linux / Hyprland desktop operations
```

建议：

```text
archlinux-desktop-ops | local repo | codex | archlinux | default | platform-gated; do not install on macOS
```

行为：

- macOS: 跳过安装。
- 非 Arch Linux: 跳过安装。
- Arch Linux: 可安装；具体 Hyprland 操作由 skill 描述和命令存在性继续约束。

后续可选重命名：

- 保留 `archlinux-desktop-ops` 这个名字，最清晰。
- 不建议改成泛化的 `desktop-ops`，因为内容非常 Arch/Hyprland 特化。

### docx

现状：

```text
docx | github / anthropics/skills | codex | default | candidate
```

当前 Codex App 已有 `documents` plugin，且其 `documents` skill 明确覆盖 `.docx` 创建、编辑、redline、comment 和渲染检查。

建议：

```text
docx | builtin / openai-primary-runtime documents | codex | runtime-builtin | builtin:documents | replaced by Codex App Documents plugin
```

或者直接从 active install list 移除，改放到 “replaced/deprecated notes”。

行为：

- Codex App: 不安装外部 `docx` skill，使用内置 `Documents` 插件。
- Codex CLI 无插件环境: 后续再决定是否需要 fallback。

### pdf

现状：

```text
pdf | github / anthropics/skills | codex | default | candidate
```

当前未发现 Codex App 有独立 `pdf` 插件/skill。`documents` plugin 能渲染 DOCX 到 PDF，但不等于通用 PDF 编辑/抽取/合并/压缩能力。

建议先降级为待确认：

```text
pdf | github / anthropics/skills | codex | all | default | review-needed; keep only if it covers non-DOCX PDF operations not handled by built-ins
```

后续检查点：

- 如果用户常用 PDF 阅读、拆页、合并、OCR、表格抽取，保留或替换为更明确的 PDF skill。
- 如果只是 DOCX 导出 PDF，删除外部 `pdf` skill，交给 `documents`。

### skill-creator

现状：

```text
skill-creator | github / anthropics/skills | codex | default | candidate
```

当前 Codex App 已有系统 skill：

```text
~/.codex/skills/.system/skill-creator
```

建议：

```text
skill-creator | builtin / codex system skill | codex | runtime-builtin | builtin | do not install duplicate
```

行为：

- Codex App: 不安装外部副本。
- Claude Code / Hermes: 如果需要另行维护对应版本，单独加目标，不从 Codex 内置 skill 推断。

### frontend-design

当前 repo 里 `.codex/skills/frontend-design` 存在，同时 catalog 指向 `github / anthropics/skills`，目标是 `codex, claude-code`。

建议检查后决定：

- 如果本地 `.codex/skills/frontend-design` 是定制版，source 应改成 `local repo` 或迁入 `agent-skill-manager/public_skills/frontend-design`。
- 如果不需要定制，保持 GitHub source，但不要同时维护运行时副本和 catalog source。

暂定：

```text
frontend-design | github / anthropics/skills | codex, claude-code | all | default | keep; verify source vs local runtime copy
```

### tapestry

当前 repo 里 `.codex/skills/tapestry` 存在，catalog 指向 GitHub。

建议和 `frontend-design` 一样处理 source of truth 一致性。

暂定：

```text
tapestry | github / michalparkola/tapestry-skills-for-claude-code | codex, claude-code | all | default | keep; verify source vs local runtime copy
```

### gstack

当前 `AGENTS.override.md` 已经在使用 gstack instructions，且 special install 文档存在。

建议保留：

```text
gstack | github / garrytan/gstack | codex, claude-code | all | special:gstack | keep; verify macOS setup flow
```

注意：

- gstack 本身可能生成多个 subskills。
- 安装验证应检查 `browse`, `qa`, `review`, `office-hours` 等代表性 subskills。

## Private Catalog 建议调整

### mainliufeng-local-env

现状：仍然值得保留，但正文里偏 Arch Linux 历史路径，缺少 macOS 说明。

建议保留目标：

```text
mainliufeng-local-env | private local repo | codex, claude-code, hermes | all | default | update for macOS/Arch Linux path model
```

建议修改正文：

1. 增加平台识别：

```text
- macOS 主机通常是 `/Users/liufeng`
- Arch Linux 主机通常是 `/home/liufeng`
- 文档中优先使用 `~`，只有必须给绝对路径时再按平台展开
```

2. 更新 dotfiles 结构：

```text
- `~/dotfiles/setup.sh` 和 `~/dotfiles/link.sh` 是跨平台顶层入口
- `~/dotfiles/macos/` 放 macOS 专用安装和链接
- `~/dotfiles/linux/` 放 Arch Linux/桌面/服务/硬件专用配置
- 根目录其他模块默认按通用处理
```

3. 更新默认目录规则：

当前 macOS 上 `~/Code` 不存在或未确认存在，不能硬断言。

建议改成：

```text
- 如果 `~/Code/self` 存在，新建个人 repo 默认放这里。
- 如果不存在，先询问是否创建 `~/Code/self/<repo>`，不要默认写到其他位置。
- 外部源码优先 `~/Code/source`，但路径不存在时先询问或创建。
```

4. 增加运行时目录：

```text
- Codex skills: `~/.codex/skills`
- Claude Code skills: `~/.claude/skills`
- Hermes skills: `~/.hermes/skills`
- Codex App plugin cache: `~/.codex/plugins/cache`
```

5. 增加 macOS 注意事项：

```text
- Homebrew prefix on Apple Silicon: `/opt/homebrew`
- Codex App CLI may live at `/Applications/Codex.app/Contents/Resources/codex`
- Ghostty config: `~/.config/ghostty/config`
- macOS app installs usually由 `~/dotfiles/macos/Brewfile` 管理
```

### content-creator / knowledge

建议保留：

```text
content-creator | private local repo | codex, hermes | all | default | keep
knowledge | private local repo | codex, hermes | all | default | keep
```

但正文里如果引用 `/home/liufeng`，需要改为 `~` 或平台条件。

### rcrai*

这些是组织/工作流私有 skill，和 OS 关系不大。

建议保留 Codex 目标：

```text
rcrai* | private local repo | codex | all | default | keep
```

后续只检查其中是否硬编码 Arch Linux 绝对路径。

### manju-auto-studio

当前仅 Hermes：

```text
manju-auto-studio | private local repo | hermes | all | default | keep; verify heavy generated outputs not installed
```

注意该目录里有 `out/` 产物，安装时不要把大产物无差别复制进运行时。

## Catalog 表结构草案

公共 catalog 建议改成：

```markdown
| skill | source | targets | platforms | mode | status |
|---|---|---|---|---|---|
| commit | local repo | codex, claude-code, hermes | all | default | keep |
| archlinux-desktop-ops | local repo | codex | archlinux | default | skip on macOS |
| docx | builtin / openai-primary-runtime documents | codex | runtime-builtin | builtin:documents | no external install |
| pdf | github / anthropics/skills | codex | all | default | review-needed |
| skill-creator | builtin / codex system skill | codex | runtime-builtin | builtin | no external install |
```

私有 catalog 同步加 `platforms` 列：

```markdown
| skill | source | targets | platforms | mode | status |
|---|---|---|---|---|---|
| mainliufeng-local-env | private local repo | codex, claude-code, hermes | all | default | macOS/Arch Linux path rules |
```

## 安装行为草案

manager skill 后续安装时按以下顺序处理：

1. 读取公共 catalog。
2. 如果存在，读取私有 catalog overlay。
3. 检测当前平台：
   - `uname -s`
   - Linux 下用 `/etc/os-release` 确认 Arch Linux
   - 可选检测 `hyprctl` / `$XDG_CURRENT_DESKTOP`
4. 检测运行时：
   - `~/.codex/skills`
   - `~/.claude/skills`
   - `~/.hermes/skills`
   - Codex App plugin cache
5. 对每个 catalog entry：
   - target 不匹配：skip
   - platform 不匹配：skip
   - mode 是 `runtime-builtin` 或 `builtin:*`：verify builtin exists, do not install external copy
   - mode 是 `special:*`：读取对应 special install doc
   - mode 是 `default`：按 runtime install-default doc 安装

## 建议实施步骤

### Step 1: 更新 catalog schema

修改：

- `agent-skill-manager/skill/assets/skill-catalog.md`
- `~/dotfiles-private/agent-skill-manager/assets/private-skill-catalog.md`

加入 `platforms` 列，并先完成以下关键项：

- `archlinux-desktop-ops`: `archlinux`
- `docx`: `runtime-builtin`
- `skill-creator`: `runtime-builtin`
- `mainliufeng-local-env`: `all`

### Step 2: 更新 mainliufeng-local-env

修改：

- `~/dotfiles-private/agent-skill-manager/private_skills/mainliufeng-local-env/SKILL.md`

加入 macOS/Arch Linux 路径规则、dotfiles 新布局、Codex App 插件缓存说明。

### Step 3: 降噪 archlinux-desktop-ops

短期只改 catalog，不动 skill 正文。

后续可在 `archlinux-desktop-ops/SKILL.md` frontmatter 描述里明确：

```text
Only use on Arch Linux / Hyprland hosts. Do not use on macOS.
```

这样即使误装到 macOS，也不容易触发。

### Step 4: 处理 docx/pdf

`docx`：

- 从外部安装候选降级为 Codex App builtin marker。
- 不再安装 anthropics `docx` skill 到 Codex App。

`pdf`：

- 暂时保留但标记 `review-needed`。
- 后续用实际 PDF 任务验证是否仍需要外部 skill。

### Step 5: 做一次 runtime audit

运行时检查：

- `~/.codex/skills`
- `~/.claude/skills`
- `~/.hermes/skills`
- `~/.codex/plugins/cache/openai-primary-runtime`

输出：

- installed
- builtin
- catalog-only
- stale/runtime-only
- skipped by platform

## 风险

- 加 `platforms` 列会要求 agent-skill-manager 以后解析新版表格；如果现有流程只人工读取，风险很低。
- `docx` 外部 skill 如果有内置 Documents 没覆盖的功能，直接删除可能损失能力；所以建议先标记 builtin/replaced，不删除历史记录。
- `mainliufeng-local-env` 是高触发私有 skill，改得太长会污染上下文；应保持正文简洁，把细节放 references 里，或用短规则覆盖。

## Review 问题

1. `docx` 是否直接从 active catalog 移除，还是保留为 `runtime-builtin` marker？
2. `pdf` 是否继续安装外部 skill，还是也等 Codex 内置 PDF 能力出现后再处理？
3. `archlinux-desktop-ops` 是否只做 platform gate，还是从 Codex targets 移除，改成 Arch Linux 机器专用 overlay？
4. `mainliufeng-local-env` 里的 `~/Code/self`、`~/Code/source` 是否应该在 macOS 上自动创建，还是只作为“存在时使用”的默认？
5. 是否要把 `.codex/skills/frontend-design`、`.codex/skills/tapestry` 这类 repo-local runtime 副本纳入 catalog source of truth，避免 GitHub source 与本地副本分叉？
