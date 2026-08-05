# Chinese content skill catalog

## Adoption and selection table

| Listed skill | Distinctive value found in the source | Local adoption | Exact upstream trigger | Source to read |
| --- | --- | --- | --- | --- |
| Humanizer-zh | A concrete taxonomy of AI-writing patterns and a directness/rhythm/trust/authenticity/conciseness review. | Referenced as the last prose pass; not copied because the exact MIT upstream is active. | User asks to humanize/review a finished draft, or local final review finds machine-like prose after facts and structure are stable. | `~/.local/share/agent-skill-manager/skills/humanizer-zh/SKILL.md` |
| dbskill | Content-completeness-before-hook, topic + hook + credibility, resonance diagnosis, script-flow checks, and a 75-formula Xiaohongshu title library. | Checkpoints are adopted in local editorial routing. Formula tables and diagnostics stay in the exact CC BY-NC child skills. | Explicit commercial-angle, short-video hook/script, resonance, benchmark, or Xiaohongshu-title task. Start at `dbs`, then load one narrow child. | `~/.local/share/agent-skill-manager/skills/dbskill/skills/dbs/SKILL.md` |
| content-research-writer | Mark research debt in the outline, maintain claim/citation coverage, and review a draft section by section. | Independently worded research-gap ledger and section gate adopted into local article production. The AGPL repository implementation is not copied. | Only when the user explicitly asks for the OpenAkita workflow or its exact artifact convention. | `~/.local/share/agent-skill-manager/skills/openakita-content-writer/skills/content-research-writer/SKILL.md` |
| notebooklm-skill | Grounded synthesis over a user-controlled corpus and explicit artifact generation. | Local `notebooklm` CLI is canonical; Knowledge now has an explicit corpus trigger and treats notebook answers as source-guided synthesis. | User names NotebookLM, or the authoritative corpus already lives in one notebook. | `~/.local/share/agent-skill-manager/skills/claude-world-notebooklm/SKILL.md` |
| khazix-skills | Horizontal/vertical research, HKR topic lens, article archetypes, human/AI contribution boundary, ascending reveal, callback, and layered review. | Research lens and narrative checkpoints adopted in independent wording. Personal voice, catchphrases, forced punctuation, and impersonation are rejected. | User explicitly requests Khazix's method or a 10k-30k horizontal/vertical report/PDF. | `~/.local/share/agent-skill-manager/skills/khazix-skills/hv-analysis/SKILL.md` or `.../khazix-writer/SKILL.md` |
| ian-xiaohei-illustrations | Cognitive-anchor shot lists and a coherent character-led hand-drawn explanatory system. | Shot-list schema and “one image, one cognitive change” adopted. Xiaohei IP/style remains an explicit specialty route. | User asks for Xiaohei/Ian/怪诞手绘正文配图. | `~/.local/share/agent-skill-manager/skills/ian-xiaohei-illustrations/ian-xiaohei-illustrations/SKILL.md` |
| guizang-social-card-skill | One idea per card, evidence-led screenshots, separate ratio compositions, subject maps, thumbnail checks, and strict mobile density. | General visual QA and carousel planning adopted. AGPL templates, recipes, validators, and Live Photo production remain upstream. | User asks for Guizang, Xiaohongshu cards, 21:9 + 1:1 WeChat cover pairs, Editorial/Swiss cards, or Live Photo cards. | `~/.local/share/agent-skill-manager/skills/guizang-social-card-skill/SKILL.md` |
| baoyu-skills | Type × style × palette illustration planning; six-dimensional covers; structured-content-before-prompt infographics; saved prompts; reference-image consistency chains. | General decomposition, reproducibility, and consistency rules adopted. Exact galleries/scripts remain upstream MIT assets. | User requests a Baoyu style/preset, comics, generated image slide deck, or a listed Baoyu specialty artifact. | `~/.local/share/agent-skill-manager/skills/baoyu-skills/skills/<selected-skill>/SKILL.md` |
| guizang-ppt-skill | Template-locked browser-native editorial/Swiss decks, page rhythm, registered layouts, and rendered deck validation. | Output-choice and visual QA rules adopted. AGPL templates and validators stay upstream. | User explicitly asks for a Guizang-style or single-file browser-native horizontal presentation. | `~/.local/share/agent-skill-manager/skills/guizang-ppt-skill/SKILL.md` |
| html-anything | A standalone interactive artifact taxonomy, behavior-level style contracts, privacy defaults, and desktop/mobile browser verification. | Output boundary and fidelity gate adopted. It is not the default renderer for an ordinary Knowledge article. | User asks for a standalone interactive/shareable HTML page, teaching studio, dashboard, atlas, browsable report, or names html-anything. | `~/.local/share/agent-skill-manager/skills/html-anything/SKILL.md` |

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

- Generic “调研 / 写文章 / 做封面 / 生成配图” requests do not select this
  router. They select `knowledge` plus `content-quality-director`, which apply
  the adopted checkpoints and call this library only for a narrow specialty.
- For the user's own `knowledge` work, retain local research-first and evidence
  rules even if an upstream workflow starts directly from drafting.
- Use dbskill before drafting when the uncertainty is commercial angle, audience,
  hook, or title; use content-research-writer when the uncertainty is evidence,
  structure, and citation coverage.
- Use NotebookLM when the authoritative corpus already lives in a notebook. Do
  not re-upload it or create a second authentication stack.
- Run Humanizer-zh last. Never let stylistic rewriting alter facts, quotes,
  numbers, or citation boundaries.
