# Quality gates

## Structural checks

- Every directed edge has `marker-end`.
- Every marker uses `markerUnits="userSpaceOnUse"`; marker size must not scale with connector stroke width.
- Every edge has a source node and target node.
- The path endpoint equals the target port on the node boundary.
- Return loops use an outer gutter and do not cut through nodes.
- Parallel edges use separate lanes or are intentionally bundled.
- Groups do not cover node labels or connector tips.
- Repeated units have identical size and spacing.
- No topology edge is represented by a Unicode arrow glyph or a standalone triangle.
- The final segment entering a node is at least 1.5 times the arrowhead length. If there is not enough room, reroute or move nodes.

## Connector rules (hard fails)

- **Label-to-connector gap: 6–10px, always.** Every arrow label needs an opaque mask rect behind it (otherwise the line bleeds through), and the mask must sit with a visible 6–10px gap above the stroke. A label that touches or hides its own arrow is a hard fail. Never `writing-mode` vertical text on arrows.
- **Fan the attach points.** When two or more connectors enter or exit the same edge of a box, each gets its own attach point spread along the edge, ≥12px apart (8px minimum for very small boxes). No two connectors may share one point; no connector may hide another.
- **No overlapping connectors.** Two connectors must never share a stroke path or run on top of each other. Crossings use a bridge / hop primitive; parallel connectors keep ≥12px separation end to end. If you find yourself stacking connectors, split the diagram.
- **No connector passes behind a non-endpoint box — except when geometrically unavoidable on the direct orthogonal path.** In that narrow exception the stroke must be dashed (transit, not interaction), the label sits at the visible end, and no arrowhead lands on the intervening box.
- **Label masks must not overlap nodes painted after them.** A mask that lands inside a later node gets clipped by the node fill and the text renders as a fragment on the border. Place labels on segments running through open canvas.

## Anti-patterns (AI-slop markers)

These mark "AI generated" schematics of any type. Reject them at review:

| Anti-pattern | Why it fails |
|---|---|
| Dark mode + cyan/purple glow | Looks "technical" without design decisions |
| Monospace as a blanket "dev" font | Mono is for technical content — ports, commands, URLs. Names go in the body font |
| Identical boxes for every node | Erases hierarchy |
| Legend floating inside the diagram area | Collides with nodes |
| Arrow labels with no masking rect | Bleeds through the line |
| Vertical `writing-mode` text on arrows | Unreadable |
| 3 equal-width summary cards as default | Generic grid — vary widths |
| Shadow on every element | Borders are the default; shadows only for deliberate elevation |
| `rounded-2xl` on boxes | Max radius 16–24px or none |
| Accent color on every "important" node | Accent is 1–2 focal elements, not a signaling system |
| Reproducing Mermaid's renderer layout | Imports automatic spacing and routing instead of an editorial layout |
| Diagonal connectors between off-axis nodes | Orthogonal elbows are mandatory for process routing |

## Complexity budget check

- Node count ≤ 9, arrows ≤ 12, focal elements ≤ 2. Exceeding any limit: split into overview + detail.
- Hub-spoke: 4–8 outer cards. Sequence: ≤ 5 lifelines. Return loops: ≤ 2, each in its own outer gutter.
- Per-type limits: quadrant ≤ 12 items; timeline ≤ 8 events; swimlane ≤ 5 lanes and ≤ 10 steps; tree depth ≤ 4 and ≤ 12 nodes; venn ≤ 3 sets; pyramid ≤ 6 levels; layers ≤ 6.
- If the diagram cannot be read as one dominant path with branches, it is two diagrams.

## 4px grid check

- Every rect `x/y/width/height`, text `x/y/font-size`, and gap is a multiple of 4. `validate_diagram.py` flags off-grid values; fix before publication.
- Exempt by design: stroke widths, opacity, `y + h/2` baseline offsets, and renderer-computed geometry (comparison panel widths, hub-spoke polar card positions, edge label masks, ring sectors). The grid applies to *declared* geometry — node boxes, group boxes, fonts, and manually authored coordinates in the spec.

## Accessibility check

- The exported SVG carries `role="img"` and an accessible name. When inlining into HTML, add `<title>` as the first child of `<svg>` and a one-sentence `<desc>` describing the content (not the geometry), with IDs prefixed per diagram — never bare `title` / `desc` IDs, which collide when several diagrams are inlined on one page.
- Decorative-only graphics get `aria-hidden="true"` instead of an accessible name.

## Visual checks

Inspect the PNG at full size and at 390 px wide.

- The main path is visible before reading labels.
- No arrowhead is detached, hidden under a node, or pointing in the wrong direction.
- Every arrow still has a visible shaft at 390 px. A triangle with no handle, or a handle visually shorter than its head, fails review.
- No connector crosses a label.
- No text touches a node boundary.
- Equivalent items align.
- The smallest important label remains legible on mobile.
- There is one visual center.
- Decorative color does not imply a false category.

## Content checks

- Arrows encode real semantics, not proximity.
- Sequence order, state transitions, and ownership boundaries are accurate.
- A comparison uses the same dimensions and scale on both sides.
- A cache diagram distinguishes reused, newly computed, invalidated, and recomputed regions.
- The title states the subject, while the diagram shows the relationship.

## Reference-match checks

- The new image preserves the reference's region proportions and reading order.
- The content, palette, typography, icons, and branding are original.
- Layout matching does not become pixel copying.

## Failure responses

- Detached arrowhead: fix marker `refX`, target port, or path endpoint. Do not paste a triangle onto the canvas.
- Oversized triangle or missing handle: set `markerUnits="userSpaceOnUse"`, reduce the fixed marker size, and lengthen the final shaft. Do not compensate by shrinking the whole canvas.
- Short connector gap: widen the nodes' gap or route through a dedicated gutter. Do not use `→`/`←` characters as a shortcut.
- Busy return paths: reserve an outer gutter and allow only one loop per gutter.
- Crowded nodes: shorten labels or split the diagram. Do not shrink all text.
- Poor mobile readability: change the canvas orientation or split the figure before increasing resolution.
- Mermaid drift: switch to explicit SVG when exact composition is part of the message.
