# Layout selection

Choose the layout from the relationship that must become obvious.

| Reader question | Layout family | Preferred renderer | Avoid |
|---|---|---|---|
| What surrounds or optimizes one core system? | Hub-spoke | Deterministic SVG `hub-spoke` | Force-directed graph, image generation |
| How do several detailed mechanisms explain one central system? | Annotated hub with mini-diagrams | Deterministic SVG `annotated-hub` | Text-only cards, one giant graph |
| How do two approaches differ under the same dimensions? | Side-by-side comparison | Deterministic SVG `comparison` or explicit `flow` panels | Two unrelated illustrations |
| What changes over repeated calls or time? | Timeline / segmented bars | Deterministic SVG `timeline` (events) or `comparison` (repeated cost) | Generic flowchart |
| Which prompt tokens are reused, appended, or invalidated? | Token strip / matrix | Deterministic SVG `token-prefix` | Mermaid |
| What steps, branches, and loops occur? | Port-routed flow | Deterministic SVG `flow`; Mermaid only for simple graphs | Image generation |
| How do two axes decide priorities or positioning? | 2×2 quadrant | Deterministic SVG `quadrant` | Bar chart of one axis |
| What is the stack or abstraction order? | Layer stack | Deterministic SVG `layers` | One giant ungrouped graph |
| Who does what, in which order, across roles? | Swimlane | Deterministic SVG `swimlane` | Separate per-role diagrams |
| How does one root decompose into children? | Tree / hierarchy | Deterministic SVG `tree` | Nested boxes without edges |
| Which sets overlap and what lives in the intersection? | Venn | Deterministic SVG `venn` | Three stacked boxes |
| What tapers from many to few (or the reverse)? | Pyramid / funnel | Deterministic SVG `pyramid` | Bar chart |
| Who sends what to whom, and in what order? | Sequence diagram | Mermaid `sequenceDiagram` | Hand-positioned boxes |
| Which states and transitions are legal? | State diagram | Mermaid state diagram | Architecture boxes |
| What are the ownership or deployment boundaries? | Layered architecture | Deterministic SVG `flow` with groups | One giant ungrouped graph |
| What should stop a reader while scrolling? | Cover / hero | Image model or sparse deterministic cover | Dense architecture diagram |

## Selection heuristics

- Use `hub-spoke` only when the center is semantically privileged. Do not use it for an ordinary chain.
- Use `annotated-hub` when each outer item needs its own explanatory mini-diagram. Lay out the center and all mini-diagrams first, reserve connector corridors, then add curved routes.
- Use smooth cubic curves for radial explanation links. Reserve straight radial lines for measurement, strict symmetry, or intentionally mechanical network topology.
- Use `comparison` only when both sides answer the same question. Align equivalent dimensions horizontally.
- Use `token-prefix` when position matters more than component identity.
- Use `flow` when edge topology matters more than chronological message timing.
- Use a sequence diagram when lifelines and message order are the primary facts.
- Split a diagram when it needs more than one visual center or more than two independent return loops.

## Engine boundaries

- Mermaid is fast and semantically strong for ordinary flow, sequence, state, class, and ER diagrams. It is weak when exact node coordinates and bespoke routing are part of the explanation.
- Graphviz `dot` is useful for hierarchical directed graphs. `twopi` is useful for radial graph exploration. Treat both as layout drafts when publication geometry must match a reference.
- Explicit SVG is the final authority for port attachment, radial callouts, repeated token cells, nested panels, and reference-matched composition.
- Image generation is appropriate for atmosphere, metaphor, people, environments, and non-literal covers. It is not a geometry engine.
