---
name: chinese-content-toolkit
description: Route Chinese content-production work across the installed research, writing, humanization, illustration, social-card, cover, slide, and HTML skill sources. Use when the user wants to turn a topic, article, notes, sources, or script into a researched Chinese article, long-form analysis, article illustrations, Xiaohongshu cards, WeChat covers, visual summaries, web slides, or a polished HTML artifact, especially when choosing among Humanizer-zh, dbskill, NotebookLM, Khazix, Ian Xiaohei, Guizang, Baoyu, or html-anything.
---

# Chinese Content Toolkit

Act as a method router, not a second all-in-one content workflow. Keep the
existing `knowledge` and `content-quality-director` skills in charge of repo
placement, evidence boundaries, editorial decisions, and release quality. Load
only the smallest upstream procedure needed for the current production step.

## Route the task

1. Read [references/catalog.md](references/catalog.md).
2. Select one primary method. Add a second only when the deliverables genuinely
   cross stages, such as article plus social cards.
3. Read the selected upstream `SKILL.md` completely. Read only its referenced
   files needed for this task.
4. Follow local repo and media rules over conflicting upstream defaults.
5. Verify the real output: text quality for writing, rendered images for visual
   work, browser rendering for HTML or web slides, and platform constraints for
   publishing assets.

## Preserve local authority

- Use `knowledge` for research/content_create boundaries and artifact paths.
- Use `content-quality-director` for externally published article or video
  quality gates.
- Use the local `notebooklm` skill and CLI as the canonical NotebookLM runtime;
  Claude-World supplies only the higher-level research-to-draft method.
- Use `web-access` for public research and `chrome-access-routing` before any
  task depending on the user's real Chrome login state.
- Use the available image-generation capability for generation. Do not assume
  an upstream provider, API key, or model is configured.

## Safety and quality boundaries

- Do not publish, upload, post, or send anything unless the user explicitly asks
  for that external action.
- Do not activate `baoyu-danger-gemini-web` or
  `baoyu-danger-x-to-markdown`; they use reverse-engineered interfaces. Prefer
  supported image generation and web-access routes.
- Do not install nested dependencies or additional skills ad hoc. Route missing
  capability through `agent-skill-manager`.
- Never expose cookies, API keys, browser profiles, NotebookLM session state, or
  credentials. Keep private source data out of third-party LLM calls unless the
  task explicitly authorizes that data flow.
- Treat Khazix's personal voice as an example, not the user's voice. Reuse its
  long-form structure and anti-slop checks without impersonating the author.
- Preserve source licenses and attribution when copying upstream code, templates,
  or assets; do not assume generated output removes redistribution obligations.
- Humanization improves prose; it is not a promise to evade AI-content
  detectors. Optimize for truthful, specific, natural writing.

## Multi-output order

For a complete content package, work in this order:

1. Evidence and source grounding.
2. Angle, hook, and outline.
3. Draft and editorial revision.
4. Humanization after facts and structure stabilize.
5. Visual system, illustrations, cards, covers, slides, or HTML.
6. Rendered-output inspection and platform-specific validation.

Do not let downstream packaging silently rewrite factual claims from the
approved article.

## Missing sources

Run the managed sync when a catalog path is absent:

```bash
~/dotfiles/agent-skill-manager/bin/skill-manager sync
```

Use [scripts/validate_sources.sh](scripts/validate_sources.sh) to verify all ten
listed sources and the local router after syncing.
