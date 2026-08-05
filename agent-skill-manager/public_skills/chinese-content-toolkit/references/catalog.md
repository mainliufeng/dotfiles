# Chinese content skill catalog

## Selection table

| Listed skill | Local status | Use it for | Source to read |
| --- | --- | --- | --- |
| Humanizer-zh | Active, existing exact upstream | Final Chinese prose pass: remove empty abstraction, canned transitions, repetitive triads, and machine-like rhythm. | `~/.local/share/agent-skill-manager/skills/humanizer-zh/SKILL.md` |
| dbskill | Active, existing exact upstream | Commercial angle diagnosis, hooks, content structure, AI-writing diagnosis, and Xiaohongshu titles. Start at `dbs` and let it route to the narrow child. | `~/.local/share/agent-skill-manager/skills/dbskill/skills/dbs/SKILL.md` |
| content-research-writer | Cold reference | Research-backed long-form articles, newsletters, tutorials, citations, hook iteration, outline and section feedback. | `~/.local/share/agent-skill-manager/skills/openakita-content-writer/skills/content-research-writer/SKILL.md` |
| notebooklm-skill | Cold reference; local CLI is canonical | Source-grounded research → synthesis → draft pipelines over the user's NotebookLM corpus. | `~/.local/share/agent-skill-manager/skills/claude-world-notebooklm/SKILL.md` |
| khazix-skills | Cold pack | `hv-analysis` for deep horizontal/vertical research and `khazix-writer` for long-form workflow ideas. Reuse method, never copy Khazix's personal voice as the user's. | `~/.local/share/agent-skill-manager/skills/khazix-skills/hv-analysis/SKILL.md` or `.../khazix-writer/SKILL.md` |
| ian-xiaohei-illustrations | Cold reference | Distinctive Chinese article illustrations using the Xiaohei hand-drawn visual language and an illustration shot list. | `~/.local/share/agent-skill-manager/skills/ian-xiaohei-illustrations/ian-xiaohei-illustrations/SKILL.md` |
| guizang-social-card-skill | Cold reference | Magazine/Swiss-style Xiaohongshu cards, WeChat cover pairs, and supported Live Photo layouts. | `~/.local/share/agent-skill-manager/skills/guizang-social-card-skill/SKILL.md` |
| baoyu-skills | Cold pack | Broad visual production: article illustrations, covers, infographics, comics, diagrams, image slide decks, Xiaohongshu cards, Markdown formatting, and WeChat HTML. | `~/.local/share/agent-skill-manager/skills/baoyu-skills/skills/<selected-skill>/SKILL.md` |
| guizang-ppt-skill | Cold reference | Single-file horizontal web presentations in editorial-magazine or Swiss style. | `~/.local/share/agent-skill-manager/skills/guizang-ppt-skill/SKILL.md` |
| html-anything | Cold reference | Turn rich answers, files, folders, URLs, or exports into a polished single-file HTML artifact. | `~/.local/share/agent-skill-manager/skills/html-anything/SKILL.md` |

## Visual choice

- Choose Ian for a coherent hand-drawn IP and conceptual article illustrations.
- Choose Guizang social cards for magazine/Swiss layouts, covers, and motion-card
  treatments.
- Choose Baoyu for broader style exploration, infographics, comics, diagrams,
  image-based slide decks, or WeChat-oriented HTML.
- Choose Guizang PPT for a browser-native horizontal presentation.
- Choose html-anything for a standalone interactive or document-like HTML page,
  not automatically for every article.

## Baoyu allowlist

Prefer these content-production children:

- `baoyu-article-illustrator`
- `baoyu-comic`
- `baoyu-cover-image`
- `baoyu-diagram`
- `baoyu-format-markdown`
- `baoyu-image-gen`
- `baoyu-infographic`
- `baoyu-markdown-to-html`
- `baoyu-slide-deck`
- `baoyu-xhs-images`

Publishing children (`baoyu-post-to-*`) require an explicit publishing request
and the applicable browser/platform workflow. Do not use the two `danger-*`
children. Utilities unrelated to the requested content deliverable remain cold.

## Overlap rules

- For the user's own `knowledge` work, retain local research-first and evidence
  rules even if an upstream workflow starts directly from drafting.
- Use dbskill before drafting when the uncertainty is commercial angle, audience,
  hook, or title; use content-research-writer when the uncertainty is evidence,
  structure, and citation coverage.
- Use NotebookLM when the authoritative corpus already lives in a notebook. Do
  not re-upload it or create a second authentication stack.
- Run Humanizer-zh last. Never let stylistic rewriting alter facts, quotes,
  numbers, or citation boundaries.
