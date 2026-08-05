---
name: notebooklm
description: 通过 `notebooklm` CLI 直接访问 Google NotebookLM。支持 notebook/source/chat/artifact 全链路操作，包括报告、闪卡、脑图、数据表生成与导出，以及 source fulltext 提取。
---

# NotebookLM

## Overview
这个 skill 基于 `teng-lin/notebooklm-py` 提供的 `notebooklm` CLI，而不是浏览器里的一次性问答脚本。

它适合这些任务：

- 查询或切换 notebook
- 添加 URL / PDF / YouTube / pasted text 等 source
- 直接提问并拿带引用的回答
- 导出 source 的 indexed fulltext
- 生成并下载 report / flashcards / mind-map / quiz / infographic / audio / video

## Prerequisites
首次使用前先确认 CLI 和登录状态：

```bash
notebooklm --version
notebooklm status
```

如果还没认证：

```bash
notebooklm login
```

## Default Workflow
1. 先看当前上下文：`notebooklm status`
2. 没有 active notebook 时先列出：`notebooklm list`
3. 需要切换 notebook 时用：`notebooklm use <notebook_id>`
4. 再执行 ask / source / artifact / download

## Research-to-Content Pipeline

当前 `notebooklm` CLI 仍是本机执行入口。用户明确要求“NotebookLM 先研究，再综合、写稿或生成内容资产”时，可按需读取 cold library 中 Claude-World 的流程参考：

```text
~/.local/share/agent-skill-manager/skills/claude-world-notebooklm/SKILL.md
~/.local/share/agent-skill-manager/skills/claude-world-notebooklm/references/pipeline_recipes.md
```

只吸收其中的 research → synthesis → content draft 流程，不另起一套认证、CLI 或 MCP。该流程只产出草稿和本地 artifact；如果还要发布到公众号、X 或其他平台，必须有用户明确发布请求，并转入对应发布 skill。

## Core Commands

### Notebook
```bash
notebooklm list
notebooklm create "My Notebook"
notebooklm use <notebook_id>
notebooklm status
```

### Source
```bash
notebooklm source list
notebooklm source add "https://example.com"
notebooklm source add ./file.pdf
notebooklm source add "https://youtube.com/..."
notebooklm source fulltext <source_id>
notebooklm source guide <source_id>
```

### Chat
```bash
notebooklm ask "What does this notebook say about X?"
notebooklm ask "What does this source say?" -s <source_id>
notebooklm ask "Summarize this with citations" --json
notebooklm history
```

### Artifact Generation
```bash
notebooklm generate report --format blog-post
notebooklm generate flashcards --quantity more
notebooklm generate mind-map
notebooklm generate quiz
notebooklm artifact list
notebooklm artifact wait <artifact_id>
```

### Download / Export
```bash
notebooklm download report ./report.md
notebooklm download flashcards --format markdown ./cards.md
notebooklm download flashcards --format json ./cards.json
notebooklm download mind-map ./mindmap.json
notebooklm download quiz --format markdown ./quiz.md
```

## Important Rules

### Safe to run directly
- `notebooklm status`
- `notebooklm list`
- `notebooklm source list`
- `notebooklm artifact list`
- `notebooklm ask "..."`
- `notebooklm source fulltext <source_id>`

### Ask before running
- `notebooklm generate *`
- `notebooklm download *`
- `notebooklm delete *`
- `notebooklm artifact wait <artifact_id>` when the wait may be long

## Parallel Use
并发 agent 不要共用 `notebooklm use` 的上下文。

优先做法：

- 用显式 notebook id，而不是依赖当前 active notebook
- 并发场景给每个 agent 单独设 `NOTEBOOKLM_HOME`

示例：
```bash
NOTEBOOKLM_HOME=/tmp/notebooklm-agent-1 notebooklm list
```

## High-Value Uses
- “把这个 notebook 里的报告导成 markdown”
- “把这批 flashcards 导成 json”
- “把这个 source 的 fulltext 拉出来”
- “给我这个 notebook 的脑图 JSON”

## Verification
以下结果说明安装基本正常：

```bash
notebooklm --version
notebooklm status
notebooklm skill status
```
