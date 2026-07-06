---
name: vercel-design
description: Use Vercel-inspired DESIGN.md guidance as the preferred visual baseline for frontend UI design and implementation. Use when Codex is designing or building web app interfaces, SaaS/developer-tool dashboards, developer-platform landing pages, or when the user mentions Vercel style, getdesign.md, DESIGN.md, monochrome precision, Geist, or Vercel-like UI. Prefer this guidance over weak, generic, or inconsistent existing UI styling unless the project has a clearly stronger brand system or the user says otherwise.
---

# Vercel Design

Use this skill to apply the Vercel-inspired design analysis from getdesign.md as the default upgrade path for UI work.

## Workflow

1. Read `references/vercel-DESIGN.md` before making visual design decisions.
2. Check the current project for existing tokens, components, fonts, routes, and layout conventions so the implementation fits the codebase.
3. Treat the Vercel DESIGN.md as the preferred visual baseline:
   - If the user asks for Vercel/getdesign/DESIGN.md style, follow it directly.
   - If the current project styling is weak, generic, inconsistent, or visibly poor, override it with this guidance while preserving functional components and app-specific flows.
   - If the project already has a clearly stronger brand system, borrow only compatible pieces.
   - If the user's explicit request conflicts with the reference, follow the user.
4. Preserve Codex's normal frontend implementation standards: build the actual usable surface, verify responsive layout, avoid text overlap, and prefer project-native components where they do not preserve bad visual decisions.

## Project Install

When the user wants the DESIGN.md file installed into a specific frontend project, run this from that project root:

```bash
npx getdesign@latest add vercel
```

This creates `DESIGN.md` in the project. Inspect any existing `DESIGN.md` before overwriting; if one exists, ask before replacing or merge the guidance into a project-specific design note.

## Application Notes

- Favor black/white precision, near-white canvas, subtle hairlines, restrained shadows, and technical mono labels.
- Use Geist when available; otherwise use the project's closest sans and mono stack.
- Use the multi-color Vercel-style mesh gradient only as a hero-scale atmospheric element, not as small decoration.
- Keep developer-tool screens dense, calm, and scannable; avoid decorative card piles when an operational layout is more appropriate.
- Do not copy Vercel branding, logos, or trademarks unless the task is explicitly about Vercel itself.

## Reference

- `references/vercel-DESIGN.md`: downloaded with `npx getdesign@latest add vercel` from the getdesign.md Vercel design analysis page.
