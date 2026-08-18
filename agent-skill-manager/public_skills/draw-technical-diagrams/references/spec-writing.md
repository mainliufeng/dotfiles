# Writing the diagram specification

Generate a diagram brief before generating drawing code.

## Semantic brief

Write these fields in plain language:

```text
reader_takeaway:
audience:
source_facts:
inference_or_opinion:
entities:
relationships:
primary_path:
secondary_paths:
comparison_dimensions:
states_or_time:
must_not_imply:
```

Do not promote an inferred relationship to a directed edge. An arrow means an actual transfer, call, transition, dependency, or ordered continuation.

## Visual brief

```text
layout_family:
reading_order:
visual_center:
regions:
node_priority:
edge_semantics:
return_loop_gutters:
label_budget:
canvas:
mobile_target:
style_tokens:
```

Use normalized coordinates when matching a reference image. Example:

```text
center hub: x 0.38-0.62, y 0.42-0.72
top cards: x 0.02-0.98, y 0.10-0.32
left cards: x 0.02-0.28, y 0.34-0.82
right cards: x 0.72-0.98, y 0.24-0.86
radial connector gutter: 24-40 px outside cards
```

## Content compression

- Title: at most one line.
- Node title: prefer 2-6 Chinese characters or 1-4 English words.
- Node body: at most two short lines.
- Edge label: prefer a verb or payload name.
- Put qualifications, evidence boundaries, and examples in the caption or surrounding article.
- Preserve domain distinctions. For example, `direct tool calls` and `code mode` are workflows, while `tool result` is data; do not draw all three as peer components.

## Complexity budget

Decide the budget before writing coordinates. When a diagram exceeds its budget, split it into overview + detail instead of compressing.

| Limit | Rule |
|---|---|
| Max nodes | 9 |
| Max arrows / transitions | 12 |
| Max focal (accent) elements | 2 |
| Max outer cards (hub-spoke) | 8 |
| Max sequence lifelines | 5 |
| Max return loops | 2 (one per outer gutter) |
| Max annotation callouts | 2 |

The budget is a planning gate, not a checklist item: if you cannot name the 1–2 things the reader should look at first, the diagram is not finished.

## 4px grid

All coordinates, node sizes, gaps, and font sizes must be multiples of 4. This is what keeps a deterministic SVG from feeling AI-generated.

| Category | Allowed values |
|---|---|
| Font sizes | 16, 20, 24, 28, 32, 40, 48 |
| Node width / height | multiples of 4 |
| x / y coordinates | multiples of 4 |
| Gap between nodes | 16, 20, 24, 32, 40 |
| Padding inside boxes | 8, 12, 16 |
| Border radius | 4, 8, 12, 16, 24 |

Exempt: stroke widths, opacity values, text baseline offsets computed as `y + h/2`, and renderer-computed geometry (comparison panel widths, hub-spoke polar card positions, edge label masks). The grid applies to declared geometry: node boxes, group boxes, fonts, and every coordinate you write in the spec. If a coordinate ends in 1, 2, 3, 5, 6, 7, 9 — fix it. `validate_diagram.py` reports off-grid values as warnings; treat them as errors before publication.

## Focal rule

One accent treatment per diagram, on 1–2 elements max. Everything else uses neutral fills. If you are tempted to accent 4 nodes, you have not decided what the reader should see first. Semantic colors (safe green / danger red) are categories, not focal accents — keep at most two semantic hues active in one diagram, plus at most two focal elements.

## JSON workflow

Copy the closest file from `assets/examples/` and replace its semantic content.

For `flow`:

- Set explicit node `x`, `y`, `w`, and `h`.
- Set `from_port` and `to_port` when the automatic choice is ambiguous.
- Use `via: left|right|top|bottom` for a return loop.
- Use groups to show ownership, deployment, or trust boundaries.

For `hub-spoke`:

- Keep 4-8 outer cards.
- Assign each card a `group`.
- Keep the center statement shorter than the outer explanations.
- Use organic cubic connectors by default. Set a card's signed `curve` between
  `-0.32` and `0.32` only when a connection must bend the other way to avoid a
  card or label; keep nearby spokes consistent so the diagram reads as one
  expanding system rather than unrelated wires.

For `annotated-hub`:

- Treat the center wheel and every outer callout as independent drawings.
- Give every callout an explicit `x`, `y`, `w`, `h`, `visual`, and connector `curve`.
- Finish the mini-diagram layout before routing connectors.
- Keep a whitespace corridor between the center wheel and callouts.
- Use curved dashed routes for explanatory association; do not imply execution order.
- Supported mini visuals include `candidate`, `compute`, `websocket`,
  `token-growth`, `memory`, `catalog`, `routing`, `timeline`, `delta`, and
  `code`.

For `comparison`:

- Align equivalent rows.
- Use the same scale on both sides.
- Use `segmented-bars` for repeated setup/payload cost and `persistent-spine` for one connection with repeated deltas.

For `token-prefix`:

- Keep equal token widths.
- Represent state through color, not changing block geometry.
- Point to the first changed token when explaining cache invalidation.

For `quadrant`:

- `quadrants` holds 4 cells in fixed order: top-right, top-left, bottom-left, bottom-right. Give each a `title`, optional `body`, and `color`.
- `items` position points by normalized `x`/`y` (0–1, y bottom-up) inside the plot area, with `label` and optional `color`.
- Axis wording lives in `x_label`/`x_high_label` (low/high cost) and `y_label`/`y_high_label` (low/high impact). Put the *actionable* quadrant top-right ("立即做").
- Keep ≤ 12 items; if labels would collide, drop the least important items instead of shrinking text.

For `timeline`:

- `events` are ordered along the axis; each has optional `date`, `title`, `body`, and `color`. Cards alternate above/below the axis automatically.
- Card width adapts to event count; if events are dense, split into two timelines or keep ≤ 8 events.
- `axis_label` sits at the right end of the axis (e.g. "时间 →").

For `layers`:

- `layers` render top-down in list order; each has `title`, optional `body`, and `color`.
- The arrow between layers points downward (dependency direction). Put the *most dependent-on* layer last.

For `swimlane`:

- `lanes` render top-down; each has `id`, `title`, `color`.
- `steps` give `id`, `lane`, `label`, optional `body`, and normalized `x` (0–1 across the lane area).
- `edges` connect step ids with optional `label`; routing is orthogonal and validated. Keep ≤ 5 lanes and ≤ 10 steps.

For `tree`:

- `nodes` list every node with `id`, `label`, optional `body`/`color`; parent nodes carry `children` (ids). `root` names the top node.
- Layout partitions width by leaf counts, so subtrees stay readable. Keep depth ≤ 4 and nodes ≤ 12.

For `venn`:

- `sets` are 2–3 circles with `title` and `color`; `labels` place free text by normalized `x`/`y` (0–1) inside the plot area.
- Keep labels sparse: one per region that carries information. Three circles max.

For `pyramid`:

- `levels` render top-down; each has `title`, optional `body`, and `color`. `mode: "pyramid"` tapers narrow at top; `mode: "funnel"` tapers narrow at bottom.
- Top levels are the focal ones — give them `coral`/`amber`, bottom `muted`. Keep ≤ 6 levels.
