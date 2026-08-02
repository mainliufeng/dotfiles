---
name: draw-technical-diagrams
description: Turn technical explanations into precise, publication-ready architecture diagrams, flowcharts, sequence diagrams, hub-and-spoke maps, side-by-side comparisons, token/cache diagrams, and technical covers. Use when Codex must decide what diagram to draw, derive a diagram brief from domain knowledge, match the spatial layout of a reference image without copying its content or style, generate SVG/PNG assets, or fix broken arrows, crowded routing, text overflow, and mobile readability.
---

# Draw Technical Diagrams

Build diagrams in two stages: derive a semantic specification, then render it with the least flexible tool that fits the layout.

## Core workflow

1. State the one sentence the reader should understand after seeing the diagram.
2. Extract entities, relationships, order, comparison dimensions, states, and boundaries from the source material.
3. Select one layout family using [layout-selection.md](references/layout-selection.md).
4. Write a diagram specification before writing SVG, Mermaid, or an image prompt. Follow [spec-writing.md](references/spec-writing.md).
5. Render:
   - Use `scripts/render_diagram.py` for `hub-spoke`, `annotated-hub`, `comparison`, `token-prefix`, and port-routed `flow` diagrams.
   - Use Mermaid for ordinary sequence, state, and small acyclic flow diagrams. Follow [mermaid-and-sequence.md](references/mermaid-and-sequence.md).
   - Use an image model only for covers, scene metaphors, or decorative illustration. Follow [cover-prompts.md](references/cover-prompts.md).
6. Export an editable source plus PNG. Never ship SVG as the only article asset.
7. Run `scripts/validate_diagram.py` and visually inspect the full-size PNG and a 390 px wide preview. Follow [quality-gates.md](references/quality-gates.md).

## Reference-image workflow

When a layout example is provided:

1. Inspect the image and describe only its spatial grammar:
   - dominant layout family;
   - normalized regions and reading order;
   - node count and relative sizes;
   - connector directions and routing channels;
   - whitespace distribution and visual center.
2. Do not copy logos, wording, icons, palette, decorative details, or exact illustration.
3. Map the new technical content into the same region structure.
4. Prefer an existing renderer layout. Use explicit `flow` coordinates when the example has a custom composition.
5. Keep the layout recognizably equivalent while making the visual language original.

## Rendering commands

Create SVG and PNG:

```bash
python3 ~/.codex/skills/draw-technical-diagrams/scripts/render_diagram.py \
  --spec ~/.codex/skills/draw-technical-diagrams/assets/examples/flow-agent-loop.json \
  --svg /tmp/agent-loop.svg \
  --png /tmp/agent-loop.png
```

Validate geometry and output:

```bash
python3 ~/.codex/skills/draw-technical-diagrams/scripts/validate_diagram.py \
  --spec ~/.codex/skills/draw-technical-diagrams/assets/examples/flow-agent-loop.json \
  --svg /tmp/agent-loop.svg \
  --png /tmp/agent-loop.png
```

Use the example specifications as structure references:

- `assets/examples/hub-spoke-agent-runtime.json`
- `assets/examples/annotated-hub-agent-optimizations.json`
- `assets/examples/comparison-transport.json`
- `assets/examples/token-prefix-cache.json`
- `assets/examples/flow-agent-loop.json`
- `assets/examples/flow-direct-vs-code-mode.json`

## Non-negotiable rules

- Attach every directed connector to an explicit source and target port.
- Put the arrow tip on the target boundary; never use a floating triangle as an arrow.
- Use renderer-generated markers for topology. For hand-authored SVG, every arrow marker must set `markerUnits="userSpaceOnUse"`; never rely on the SVG default `strokeWidth`, which can scale a marker into a large triangle when the shaft is thick.
- Keep a visible shaft before every arrowhead. The final segment into a target must be at least 1.5 times the fixed arrowhead length; if the gap is too narrow, widen the gap or route through a gutter instead of shortening the shaft.
- Never use Unicode glyphs such as `→`, `←`, `▲`, or `▶` as topology connectors. Text arrows may appear only inside prose labels, never as the line that carries an edge.
- Match connector geometry to meaning: organic cubic curves for explanatory expansion, orthogonal lines for process routing, and straight lines only for strict radial or measurement relationships.
- Route return loops through a dedicated outer gutter.
- Keep one dominant reading path. Treat secondary paths as branches, not equal-weight spaghetti.
- Keep node labels short. Move explanation into a caption or article body.
- Do not use image generation for diagrams whose correctness depends on exact arrows, repeated alignment, or token-by-token states.
- Do not use Mermaid when the reference layout requires exact geometry, nested panels, a center hub, repeated token strips, or carefully isolated return paths.
- Do not imitate a source image's brand identity. Reuse spatial grammar only.
- Treat arrow anatomy as a release gate at both full size and 390 px: the shaft, bend, and head must remain distinguishable; a head with no visible handle or a handle shorter than the head must be redrawn before publication.
