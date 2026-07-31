# Technical cover prompts

Use an image model for a cover only when the cover's job is emotion, metaphor, or visual tension.

## Prompt construction

Generate the prompt from the technical brief:

```text
Create a publication cover for [reader problem].
Single visual metaphor: [one concrete scene].
The scene must communicate [conflict or transformation] without showing a full architecture diagram.
Composition: [subject placement], [negative space], [reading direction].
Visual language: [palette, material, lighting, line style].
Include only this short text: “[cover line]”.
Do not include: logos, fake UI, tiny labels, dense flowchart nodes, decorative arrows, extra words.
Canvas: [ratio and pixels]. Keep the main subject readable at 390 px width.
```

## Domain-to-metaphor examples

- Request crosses Harness, API, Inference: one luminous data packet passing through three distinct gates.
- Direct tool calls versus code mode: a courier making repeated trips versus one workshop consolidating parts.
- Prompt caching: a long illuminated rail that remains intact while new cars attach at the end.
- Prefill/decode separation: one heavy loading dock handing a compact state bundle to a fast delivery lane.

## Boundary

Do not ask an image model to render exact architecture, sequence, token, or cache diagrams. Generate those deterministically and, if useful, composite them into a cover afterward.
