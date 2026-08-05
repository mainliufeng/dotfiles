---
name: chinese-content-toolkit
description: Inspect or invoke the imported Chinese creator-skill library without competing with the local Knowledge workflow. Use when the user explicitly names Humanizer-zh, dbskill, OpenAkita content writer, NotebookLM, Khazix, Ian Xiaohei, Guizang, Baoyu, or html-anything; asks which imported method should be used; asks to absorb/audit/update those sources; or requests a specialty artifact such as Xiaohei illustrations, Xiaohongshu cards, Guizang web slides, or a standalone interactive HTML page. Do not trigger merely because the user asks for ordinary research, an article, a cover, or an image; use knowledge plus content-quality-director for those generic requests.
---

# Chinese Content Toolkit

Act as an imported-method library and specialty-artifact router, not a second
all-in-one content workflow. Generic research, article, cover, and image work in
the user's Knowledge repository belongs to `knowledge` plus
`content-quality-director`; those local skills already contain the adopted
research, editorial, narrative, and visual checkpoints.

Use this router for one of three narrower jobs:

1. inspect, compare, update, or attribute the imported source library;
2. invoke an exact active upstream method such as Humanizer-zh or a dbskill
   child when the local workflow calls for it;
3. produce a specialty artifact whose implementation assets remain upstream,
   such as Xiaohei illustrations, Guizang cards/web slides, Baoyu visual packs,
   or an html-anything standalone page.

## Route the task

1. Read [references/catalog.md](references/catalog.md), including its adoption
   and conflict columns.
2. If the capability is already adopted into a local skill, return control to
   that local skill. Do not load the cold upstream pack merely to repeat it.
3. If an exact library or specialty artifact is needed, select one primary
   upstream method. Add a second only for a genuinely separate production
   stage, such as article plus social cards.
4. Read the selected upstream `SKILL.md` completely and only the references
   required for this task.
5. Follow local repo, evidence, privacy, media, and release rules over upstream
   defaults, then verify the real rendered output.

## Preserve local authority

- Use `knowledge` for research/content_create boundaries and artifact paths.
- Use `content-quality-director` for externally published article or video
  quality gates.
- For ordinary article planning, hook design, narrative structure, research
  gaps, human contribution, illustrations, covers, and mobile QA, use the
  adopted local references loaded by those two skills. This router must not
  become a competing trigger.
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
- dbskill's formula library remains an attributed CC BY-NC upstream reference.
  Call the exact child skill when needed; do not duplicate its formula tables
  into local public skills.
- OpenAkita and Guizang implementation templates remain upstream references.
  Reuse them only through their specialty routes and preserve the applicable
  license; local adopted rules are independently worded process abstractions.
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
