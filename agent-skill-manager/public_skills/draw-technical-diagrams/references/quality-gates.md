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
