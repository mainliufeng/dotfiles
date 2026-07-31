#!/usr/bin/env python3
"""Render deterministic technical diagrams from a JSON specification."""

from __future__ import annotations

import argparse
import html
import json
import math
import os
import shutil
import struct
import subprocess
import sys
import tempfile
import time
import unicodedata
from pathlib import Path


DEFAULT_THEME = {
    "background": "#07111F",
    "surface": "#102539",
    "surface_alt": "#153247",
    "text": "#F5F8FC",
    "muted": "#A9B8C8",
    "line": "#77A0B8",
    "grid": "#183249",
    "teal": "#42D6B5",
    "amber": "#FFB85C",
    "violet": "#9B7BFF",
    "coral": "#FF718B",
    "blue": "#69B7FF",
    "cached": "#42D6B5",
    "new": "#FFB85C",
    "invalid": "#FF718B",
    "recomputed": "#9B7BFF",
}


def esc(value: object) -> str:
    return html.escape(str(value), quote=True)


def display_units(text: str) -> float:
    total = 0.0
    for char in text:
        total += 1.0 if unicodedata.east_asian_width(char) in {"W", "F", "A"} else 0.64
    return total


def wrap_text(text: str, max_units: float) -> list[str]:
    text = str(text).strip()
    if not text:
        return []
    if display_units(text) <= max_units:
        return [text]
    tokens = text.split()
    if len(tokens) == 1:
        tokens = list(text)
        separator = ""
    else:
        separator = " "
    lines: list[str] = []
    current = ""
    for token in tokens:
        candidate = token if not current else current + separator + token
        if current and display_units(candidate) > max_units:
            lines.append(current)
            current = token
        else:
            current = candidate
    if current:
        lines.append(current)
    return lines


def text_block(
    x: float,
    y: float,
    text: str,
    *,
    width: float,
    size: float,
    fill: str,
    weight: int = 500,
    anchor: str = "middle",
    line_height: float = 1.25,
    max_lines: int = 3,
    css_class: str = "",
) -> str:
    max_units = max(4.0, width / size * 1.45)
    lines = wrap_text(text, max_units)[:max_lines]
    if not lines:
        return ""
    start_y = y - (len(lines) - 1) * size * line_height / 2
    tspans = []
    for index, line in enumerate(lines):
        dy = 0 if index == 0 else size * line_height
        tspans.append(f'<tspan x="{x:.1f}" dy="{dy:.1f}">{esc(line)}</tspan>')
    klass = f' class="{esc(css_class)}"' if css_class else ""
    return (
        f'<text{klass} x="{x:.1f}" y="{start_y:.1f}" text-anchor="{anchor}" '
        f'font-size="{size:.1f}" font-weight="{weight}" fill="{fill}">'
        + "".join(tspans)
        + "</text>"
    )


def svg_header(width: int, height: int, theme: dict, title: str) -> list[str]:
    markers = []
    for key in ("line", "teal", "amber", "violet", "coral", "blue", "cached", "new", "invalid", "recomputed", "muted"):
        markers.append(
            f'<marker id="arrow-{key}" viewBox="0 0 16 16" refX="16" refY="8" '
            'markerWidth="16" markerHeight="16" markerUnits="userSpaceOnUse" orient="auto-start-reverse" overflow="visible">'
            f'<path d="M0,0 L16,8 L0,16 Z" fill="{theme[key]}"/></marker>'
        )
    return [
        '<?xml version="1.0" encoding="UTF-8"?>',
        (
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{width}" height="{height}" '
            f'viewBox="0 0 {width} {height}" role="img" aria-label="{esc(title)}">'
        ),
        "<defs>",
        *markers,
        (
            '<pattern id="grid" width="32" height="32" patternUnits="userSpaceOnUse">'
            f'<path d="M32 0H0V32" fill="none" stroke="{theme["grid"]}" stroke-width="1"/>'
            "</pattern>"
        ),
        '<filter id="shadow" x="-20%" y="-20%" width="140%" height="140%">'
        '<feDropShadow dx="0" dy="8" stdDeviation="12" flood-opacity=".22"/>'
        "</filter>",
        "</defs>",
        f'<rect width="{width}" height="{height}" fill="{theme["background"]}"/>',
        f'<rect width="{width}" height="{height}" fill="url(#grid)" opacity=".35"/>',
    ]


def marker_for_color(theme: dict, color: str) -> str:
    for key, value in theme.items():
        if value == color and key in {"line", "teal", "amber", "violet", "coral", "blue", "cached", "new", "invalid", "recomputed", "muted"}:
            return f"arrow-{key}"
    return "arrow-line"


def card(
    x: float,
    y: float,
    w: float,
    h: float,
    title: str,
    body: str,
    *,
    fill: str,
    stroke: str,
    theme: dict,
    node_id: str = "",
) -> str:
    attrs = f' data-node-id="{esc(node_id)}" data-bbox="{x:.1f},{y:.1f},{w:.1f},{h:.1f}"' if node_id else ""
    parts = [
        f'<g{attrs} filter="url(#shadow)">',
        f'<rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" rx="24" fill="{fill}" stroke="{stroke}" stroke-width="3"/>',
        text_block(x + w / 2, y + h * (0.39 if body else 0.5), title, width=w - 36, size=30, fill=theme["text"], weight=700, max_lines=2),
    ]
    if body:
        parts.append(
            text_block(
                x + w / 2,
                y + h * 0.68,
                body,
                width=w - 42,
                size=20,
                fill=theme["muted"],
                max_lines=2,
            )
        )
    parts.append("</g>")
    return "".join(parts)


def polar(cx: float, cy: float, radius: float, angle_degrees: float) -> tuple[float, float]:
    angle = math.radians(angle_degrees - 90)
    return cx + radius * math.cos(angle), cy + radius * math.sin(angle)


def ring_sector_path(cx: float, cy: float, r0: float, r1: float, a0: float, a1: float) -> str:
    p1 = polar(cx, cy, r1, a0)
    p2 = polar(cx, cy, r1, a1)
    p3 = polar(cx, cy, r0, a1)
    p4 = polar(cx, cy, r0, a0)
    large = 1 if (a1 - a0) % 360 > 180 else 0
    return (
        f"M{p1[0]:.1f},{p1[1]:.1f} "
        f"A{r1},{r1} 0 {large} 1 {p2[0]:.1f},{p2[1]:.1f} "
        f"L{p3[0]:.1f},{p3[1]:.1f} "
        f"A{r0},{r0} 0 {large} 0 {p4[0]:.1f},{p4[1]:.1f} Z"
    )


def render_hub_spoke(spec: dict, width: int, height: int, theme: dict) -> list[str]:
    out: list[str] = []
    title = spec.get("title", "")
    subtitle = spec.get("subtitle", "")
    out.append(text_block(width / 2, 64, title, width=width - 120, size=46, fill=theme["text"], weight=800, max_lines=1))
    if subtitle:
        out.append(text_block(width / 2, 112, subtitle, width=width - 180, size=23, fill=theme["muted"], max_lines=1))
    cx, cy = width / 2, height * 0.57
    cards = spec.get("cards", [])
    groups = spec.get("groups", [])
    group_map = {g["id"]: g for g in groups}
    group_colors = [theme["teal"], theme["amber"], theme["violet"], theme["coral"], theme["blue"]]
    for index, group in enumerate(groups):
        group.setdefault("color", group_colors[index % len(group_colors)])
    ring_outer, ring_inner = 188, 126
    ring_labels: list[str] = []
    if groups:
        step = 360 / len(groups)
        for index, group in enumerate(groups):
            a0, a1 = index * step, (index + 1) * step
            out.append(
                f'<path d="{ring_sector_path(cx, cy, ring_inner, ring_outer, a0, a1)}" '
                f'fill="{group["color"]}" opacity=".92" stroke="{theme["background"]}" stroke-width="5"/>'
            )
            lx, ly = polar(cx, cy, (ring_inner + ring_outer) / 2, (a0 + a1) / 2)
            ring_labels.append(text_block(lx, ly, group.get("title", group["id"]), width=112, size=17, fill=theme["text"], weight=800, max_lines=2))
    out.append(f'<circle cx="{cx:.1f}" cy="{cy:.1f}" r="{ring_inner - 8}" fill="{theme["surface"]}" stroke="{theme["text"]}" stroke-width="4"/>')
    center = spec.get("center", {})
    out.append(text_block(cx, cy - 14, center.get("title", ""), width=190, size=30, fill=theme["text"], weight=800, max_lines=2))
    out.append(text_block(cx, cy + 54, center.get("subtitle", ""), width=190, size=20, fill=theme["muted"], max_lines=2))
    out.extend(ring_labels)
    count = max(1, len(cards))
    rx, ry = width * 0.39, height * 0.37
    card_w, card_h = width * 0.235, 156
    positions: list[tuple[float, float, float]] = []
    for index, item in enumerate(cards):
        angle = float(item.get("angle", -90 + index * 360 / count))
        px = cx + rx * math.cos(math.radians(angle))
        py = cy + ry * math.sin(math.radians(angle))
        x = max(24, min(width - card_w - 24, px - card_w / 2))
        y = max(144, min(height - card_h - 24, py - card_h / 2))
        positions.append((x, y, angle))
    for item, (x, y, angle) in zip(cards, positions):
        group = group_map.get(item.get("group"), {})
        color = group.get("color", theme["teal"])
        card_cx, card_cy = x + card_w / 2, y + card_h / 2
        vx, vy = card_cx - cx, card_cy - cy
        scale = ring_outer / max(1.0, math.hypot(vx, vy))
        sx, sy = cx + vx * scale, cy + vy * scale
        dx = max(-card_w / 2, min(card_w / 2, cx - card_cx))
        dy = max(-card_h / 2, min(card_h / 2, cy - card_cy))
        if abs(vx / max(1.0, card_w)) > abs(vy / max(1.0, card_h)):
            tx = x if vx > 0 else x + card_w
            ty = card_cy + dy * 0.15
        else:
            tx = card_cx + dx * 0.15
            ty = y if vy > 0 else y + card_h
        midx, midy = (sx + tx) / 2, (sy + ty) / 2
        path = f"M{sx:.1f},{sy:.1f} Q{midx:.1f},{midy:.1f} {tx:.1f},{ty:.1f}"
        out.append(
            f'<path d="{path}" fill="none" stroke="{color}" stroke-width="5" '
            f'stroke-dasharray="12 12" marker-end="url(#{marker_for_color(theme, color)})" opacity=".9"/>'
        )
    for index, (item, (x, y, _)) in enumerate(zip(cards, positions)):
        group = group_map.get(item.get("group"), {})
        color = group.get("color", theme["teal"])
        out.append(card(x, y, card_w, card_h, item.get("title", ""), item.get("body", ""), fill=theme["surface"], stroke=color, theme=theme, node_id=item.get("id", f"card-{index}")))
    return out


def render_comparison(spec: dict, width: int, height: int, theme: dict) -> list[str]:
    out: list[str] = []
    title = spec.get("title", "")
    out.append(text_block(width / 2, 62, title, width=width - 100, size=44, fill=theme["text"], weight=800, max_lines=1))
    panels = spec.get("panels", [])
    margin, gap, top, bottom = 48, 34, 120, 126
    panel_w = (width - margin * 2 - gap * (len(panels) - 1)) / max(1, len(panels))
    panel_h = height - top - bottom
    for index, panel in enumerate(panels):
        x = margin + index * (panel_w + gap)
        color = panel.get("color", theme["teal"])
        out.append(f'<rect x="{x:.1f}" y="{top}" width="{panel_w:.1f}" height="{panel_h:.1f}" rx="28" fill="{theme["surface"]}" stroke="{color}" stroke-width="3" stroke-dasharray="10 10"/>')
        out.append(f'<rect x="{x + panel_w * .2:.1f}" y="{top - 26}" width="{panel_w * .6:.1f}" height="58" rx="29" fill="{color}"/>')
        out.append(text_block(x + panel_w / 2, top + 5, panel.get("title", ""), width=panel_w * .55, size=27, fill=theme["background"], weight=800, max_lines=1))
        mode = panel.get("mode", "segmented-bars")
        if mode == "segmented-bars":
            rows = panel.get("rows", [])
            row_gap = (panel_h - 140) / max(1, len(rows))
            for row_index, row in enumerate(rows):
                cy = top + 95 + row_index * row_gap
                out.append(text_block(x + 72, cy, row.get("label", ""), width=110, size=22, fill=theme["text"], weight=700, max_lines=1))
                bar_x = x + 138
                available = panel_w - 176
                total = sum(float(s.get("weight", 1)) for s in row.get("segments", [])) or 1
                cursor = bar_x
                for seg in row.get("segments", []):
                    seg_w = available * float(seg.get("weight", 1)) / total
                    seg_color = theme.get(seg.get("state", ""), seg.get("color", theme["muted"]))
                    out.append(f'<rect x="{cursor:.1f}" y="{cy - 30:.1f}" width="{seg_w:.1f}" height="60" rx="10" fill="{seg_color}" stroke="{theme["text"]}" stroke-width="2"/>')
                    out.append(text_block(cursor + seg_w / 2, cy + 2, seg.get("label", ""), width=seg_w - 12, size=18, fill=theme["background"], weight=700, max_lines=1))
                    cursor += seg_w
        elif mode == "persistent-spine":
            handshake = panel.get("handshake", "handshake ×1")
            hx, hy = x + panel_w * .2, top + 72
            hw, hh = panel_w * .45, 70
            out.append(f'<rect x="{hx:.1f}" y="{hy:.1f}" width="{hw:.1f}" height="{hh}" rx="14" fill="{theme["surface_alt"]}" stroke="{theme["text"]}" stroke-width="3"/>')
            out.append(text_block(hx + hw / 2, hy + hh / 2 + 2, handshake, width=hw - 20, size=22, fill=theme["text"], weight=700, max_lines=1))
            spine_x = x + panel_w * .38
            spine_top = hy + hh
            events = panel.get("events", [])
            spine_bottom = top + panel_h - 78
            out.append(f'<path d="M{spine_x:.1f},{spine_top:.1f} V{spine_bottom:.1f}" stroke="{theme["line"]}" stroke-width="5" fill="none"/>')
            for event_index, event in enumerate(events):
                ey = spine_top + 60 + event_index * ((spine_bottom - spine_top - 100) / max(1, len(events) - 1))
                ex, ew, eh = x + panel_w * .55, panel_w * .3, 66
                out.append(f'<path d="M{spine_x:.1f},{ey:.1f} H{ex:.1f}" stroke="{theme["line"]}" stroke-width="4" fill="none" marker-end="url(#arrow-line)"/>')
                out.append(f'<rect x="{ex:.1f}" y="{ey - eh / 2:.1f}" width="{ew:.1f}" height="{eh}" rx="14" fill="{color}" stroke="{theme["text"]}" stroke-width="2"/>')
                out.append(text_block(ex + ew / 2, ey + 2, event.get("label", f"Δ {event_index + 1}"), width=ew - 18, size=22, fill=theme["background"], weight=800, max_lines=1))
        footer = panel.get("footer", "")
        out.append(text_block(x + panel_w / 2, top + panel_h - 34, footer, width=panel_w - 80, size=24, fill=color, weight=800, max_lines=1))
    legend = spec.get("legend", [])
    if legend:
        total_w = width - 120
        item_w = total_w / len(legend)
        y = height - 52
        for index, item in enumerate(legend):
            x = 60 + index * item_w
            color = theme.get(item.get("state", ""), item.get("color", theme["muted"]))
            out.append(f'<rect x="{x:.1f}" y="{y - 18:.1f}" width="36" height="36" rx="8" fill="{color}" stroke="{theme["text"]}" stroke-width="2"/>')
            out.append(text_block(x + 50, y + 2, item.get("label", ""), width=item_w - 58, size=18, fill=theme["muted"], anchor="start", max_lines=1))
    return out


def render_token_prefix(spec: dict, width: int, height: int, theme: dict) -> list[str]:
    out: list[str] = []
    title = spec.get("title", "")
    out.append(text_block(width / 2, 58, title, width=width - 100, size=42, fill=theme["text"], weight=800, max_lines=1))
    rows = spec.get("rows", [])
    outer_x, outer_y, outer_w, outer_h = 42, 110, width - 84, height - 160
    label_w = 270
    out.append(f'<rect x="{outer_x}" y="{outer_y}" width="{outer_w}" height="{outer_h}" rx="28" fill="{theme["surface"]}" stroke="{theme["line"]}" stroke-width="3"/>')
    out.append(f'<path d="M{outer_x + label_w},{outer_y} V{outer_y + outer_h}" stroke="{theme["line"]}" stroke-width="3"/>')
    row_h = outer_h / max(1, len(rows))
    max_tokens = max([len(r.get("tokens", [])) for r in rows] + [1])
    gap = 10
    usable = outer_w - label_w - 80
    token_w = min(64, (usable - gap * (max_tokens - 1)) / max_tokens)
    token_h = min(82, row_h * .34)
    for row_index, row in enumerate(rows):
        y0 = outer_y + row_index * row_h
        if row_index:
            out.append(f'<path d="M{outer_x},{y0:.1f} H{outer_x + outer_w}" stroke="{theme["line"]}" stroke-width="2" stroke-dasharray="8 10"/>')
        cy = y0 + row_h / 2
        out.append(text_block(outer_x + label_w / 2, cy, row.get("label", ""), width=label_w - 42, size=25, fill=theme["text"], weight=700, max_lines=3))
        start_x = outer_x + label_w + 42
        token_y = cy - token_h / 2 - 18
        for token_index, state in enumerate(row.get("tokens", [])):
            x = start_x + token_index * (token_w + gap)
            color = theme.get(state, theme["muted"])
            out.append(f'<rect x="{x:.1f}" y="{token_y:.1f}" width="{token_w:.1f}" height="{token_h:.1f}" rx="10" fill="{color}" stroke="{theme["text"]}" stroke-width="2"/>')
        annotations = row.get("annotations", [])
        for annotation in annotations:
            start = int(annotation.get("start", 0))
            end = int(annotation.get("end", start))
            x1 = start_x + start * (token_w + gap)
            x2 = start_x + end * (token_w + gap) + token_w
            ay = token_y + token_h + 35
            color = theme.get(annotation.get("state", ""), annotation.get("color", theme["muted"]))
            out.append(text_block((x1 + x2) / 2, ay, annotation.get("label", ""), width=max(100, x2 - x1), size=19, fill=color, weight=700, max_lines=1))
            if annotation.get("arrow"):
                tx = start_x + start * (token_w + gap) + token_w / 2
                out.append(f'<path d="M{tx:.1f},{token_y - 42:.1f} V{token_y:.1f}" stroke="{color}" stroke-width="4" marker-end="url(#{marker_for_color(theme, color)})"/>')
                out.append(text_block(tx, token_y - 56, annotation.get("arrow"), width=180, size=18, fill=color, weight=700, max_lines=1))
    return out


def node_port(node: dict, side: str) -> tuple[float, float]:
    x, y, w, h = (float(node[k]) for k in ("x", "y", "w", "h"))
    return {
        "left": (x, y + h / 2),
        "right": (x + w, y + h / 2),
        "top": (x + w / 2, y),
        "bottom": (x + w / 2, y + h),
    }[side]


def auto_ports(source: dict, target: dict) -> tuple[str, str]:
    scx = float(source["x"]) + float(source["w"]) / 2
    scy = float(source["y"]) + float(source["h"]) / 2
    tcx = float(target["x"]) + float(target["w"]) / 2
    tcy = float(target["y"]) + float(target["h"]) / 2
    dx, dy = tcx - scx, tcy - scy
    if abs(dx) >= abs(dy):
        return ("right", "left") if dx >= 0 else ("left", "right")
    return ("bottom", "top") if dy >= 0 else ("top", "bottom")


def edge_path(source: dict, target: dict, edge: dict) -> tuple[str, tuple[float, float], tuple[float, float], tuple[float, float], str, str]:
    auto_from, auto_to = auto_ports(source, target)
    from_side = edge.get("from_port", auto_from)
    to_side = edge.get("to_port", auto_to)
    sx, sy = node_port(source, from_side)
    tx, ty = node_port(target, to_side)
    via = edge.get("via")
    gutter = float(edge.get("gutter", 52))
    if via == "left":
        gx = min(float(source["x"]), float(target["x"])) - gutter
        path = f"M{sx:.1f},{sy:.1f} H{gx:.1f} V{ty:.1f} H{tx:.1f}"
        pre_end = (gx, ty)
    elif via == "right":
        gx = max(float(source["x"]) + float(source["w"]), float(target["x"]) + float(target["w"])) + gutter
        path = f"M{sx:.1f},{sy:.1f} H{gx:.1f} V{ty:.1f} H{tx:.1f}"
        pre_end = (gx, ty)
    elif via == "top":
        gy = min(float(source["y"]), float(target["y"])) - gutter
        path = f"M{sx:.1f},{sy:.1f} V{gy:.1f} H{tx:.1f} V{ty:.1f}"
        pre_end = (tx, gy)
    elif via == "bottom":
        gy = max(float(source["y"]) + float(source["h"]), float(target["y"]) + float(target["h"])) + gutter
        path = f"M{sx:.1f},{sy:.1f} V{gy:.1f} H{tx:.1f} V{ty:.1f}"
        pre_end = (tx, gy)
    elif from_side in {"left", "right"}:
        mx = (sx + tx) / 2
        path = f"M{sx:.1f},{sy:.1f} H{mx:.1f} V{ty:.1f} H{tx:.1f}"
        pre_end = (mx, ty)
    else:
        my = (sy + ty) / 2
        path = f"M{sx:.1f},{sy:.1f} V{my:.1f} H{tx:.1f} V{ty:.1f}"
        pre_end = (tx, my)
    return path, (sx, sy), pre_end, (tx, ty), from_side, to_side


def render_flow(spec: dict, width: int, height: int, theme: dict) -> list[str]:
    out: list[str] = []
    title = spec.get("title", "")
    subtitle = spec.get("subtitle", "")
    out.append(text_block(width / 2, 58, title, width=width - 100, size=44, fill=theme["text"], weight=800, max_lines=1))
    if subtitle:
        out.append(text_block(width / 2, 102, subtitle, width=width - 160, size=22, fill=theme["muted"], max_lines=1))
    groups = spec.get("groups", [])
    for group in groups:
        x, y, w, h = (float(group[k]) for k in ("x", "y", "w", "h"))
        color = theme.get(group.get("color", ""), group.get("color", theme["line"]))
        out.append(f'<g data-group-id="{esc(group["id"])}"><rect x="{x:.1f}" y="{y:.1f}" width="{w:.1f}" height="{h:.1f}" rx="28" fill="{theme["surface"]}" fill-opacity=".48" stroke="{color}" stroke-width="3" stroke-dasharray="12 10"/>')
        out.append(text_block(x + 28, y + 32, group.get("title", ""), width=w - 56, size=22, fill=color, weight=800, anchor="start", max_lines=1))
        out.append("</g>")
    nodes = {node["id"]: node for node in spec.get("nodes", [])}
    for edge_index, edge in enumerate(spec.get("edges", [])):
        source, target = nodes[edge["from"]], nodes[edge["to"]]
        path, start, pre_end, end, from_side, to_side = edge_path(source, target, edge)
        color = theme.get(edge.get("color", ""), edge.get("color", theme["line"]))
        marker = marker_for_color(theme, color)
        dash = ' stroke-dasharray="10 10"' if edge.get("dashed") else ""
        out.append(
            f'<path data-edge-id="{esc(edge.get("id", f"edge-{edge_index}"))}" '
            f'data-from="{esc(edge["from"])}" data-to="{esc(edge["to"])}" '
            f'data-from-side="{from_side}" data-to-side="{to_side}" '
            f'data-start="{start[0]:.1f},{start[1]:.1f}" data-pre-end="{pre_end[0]:.1f},{pre_end[1]:.1f}" '
            f'data-end="{end[0]:.1f},{end[1]:.1f}" '
            f'd="{path}" fill="none" stroke="{color}" stroke-width="{float(edge.get("width", 5)):.1f}" '
            f'stroke-linecap="round" stroke-linejoin="round" marker-end="url(#{marker})"{dash}/>'
        )
        if edge.get("label"):
            lx = float(edge.get("label_x", (start[0] + end[0]) / 2))
            ly = float(edge.get("label_y", (start[1] + end[1]) / 2 - 14))
            out.append(f'<rect x="{lx - 80:.1f}" y="{ly - 22:.1f}" width="160" height="34" rx="12" fill="{theme["background"]}" opacity=".94"/>')
            out.append(text_block(lx, ly, edge["label"], width=150, size=18, fill=color, weight=700, max_lines=1))
    for node in spec.get("nodes", []):
        fill = theme.get(node.get("fill", ""), node.get("fill", theme["surface_alt"]))
        stroke = theme.get(node.get("stroke", ""), node.get("stroke", theme["teal"]))
        out.append(
            card(
                float(node["x"]),
                float(node["y"]),
                float(node["w"]),
                float(node["h"]),
                node.get("label", ""),
                node.get("body", ""),
                fill=fill,
                stroke=stroke,
                theme=theme,
                node_id=node["id"],
            )
        )
    return out


def find_chrome() -> str | None:
    candidates = [
        "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
        "/Applications/Chromium.app/Contents/MacOS/Chromium",
    ]
    for candidate in candidates:
        if Path(candidate).exists():
            return candidate
    for name in ("google-chrome", "chromium", "chromium-browser"):
        found = shutil.which(name)
        if found:
            return found
    return None


def png_dimensions(path: Path) -> tuple[int, int]:
    with path.open("rb") as handle:
        header = handle.read(24)
    if header[:8] != b"\x89PNG\r\n\x1a\n":
        raise RuntimeError(f"{path} is not a PNG")
    return struct.unpack(">II", header[16:24])


def render_png(svg_path: Path, png_path: Path, width: int, height: int) -> None:
    rsvg = shutil.which("rsvg-convert")
    if rsvg:
        subprocess.run([rsvg, "-w", str(width), "-h", str(height), str(svg_path), "-o", str(png_path)], check=True)
    else:
        chrome = find_chrome()
        if chrome:
            if png_path.exists():
                png_path.unlink()
            process = None
            deadline = time.monotonic() + 20
            with tempfile.TemporaryDirectory(prefix="diagram-render-") as profile:
                process = subprocess.Popen(
                    [
                        chrome,
                        "--headless=new",
                        "--disable-gpu",
                        "--disable-background-networking",
                        "--hide-scrollbars",
                        "--no-first-run",
                        "--no-default-browser-check",
                        f"--user-data-dir={profile}",
                        "--force-device-scale-factor=1",
                        f"--window-size={width},{height}",
                        f"--screenshot={png_path}",
                        svg_path.resolve().as_uri(),
                    ],
                    stdout=subprocess.DEVNULL,
                    stderr=subprocess.DEVNULL,
                )
                try:
                    while time.monotonic() < deadline:
                        if png_path.exists() and png_path.stat().st_size > 1024:
                            break
                        if process.poll() is not None and not png_path.exists():
                            raise RuntimeError(f"Chrome exited with code {process.returncode} before writing PNG")
                        time.sleep(0.1)
                    else:
                        raise RuntimeError("Chrome did not write PNG within 20 seconds")
                finally:
                    if process.poll() is None:
                        process.terminate()
                        try:
                            process.wait(timeout=3)
                        except subprocess.TimeoutExpired:
                            process.kill()
                            process.wait(timeout=3)
        elif sys.platform == "darwin" and shutil.which("sips"):
            subprocess.run(["sips", "-s", "format", "png", str(svg_path), "--out", str(png_path)], check=True, stdout=subprocess.DEVNULL)
        else:
            raise RuntimeError("Cannot export PNG: install rsvg-convert, Chrome/Chromium, or macOS sips")
    actual = png_dimensions(png_path)
    if actual != (width, height):
        raise RuntimeError(f"PNG size mismatch: expected {(width, height)}, got {actual}")


def render(spec: dict) -> str:
    width = int(spec.get("width", 1600))
    height = int(spec.get("height", 1000))
    theme = dict(DEFAULT_THEME)
    theme.update(spec.get("theme", {}))
    layout = spec.get("layout")
    parts = svg_header(width, height, theme, spec.get("title", "technical diagram"))
    if layout == "hub-spoke":
        parts.extend(render_hub_spoke(spec, width, height, theme))
    elif layout == "comparison":
        parts.extend(render_comparison(spec, width, height, theme))
    elif layout == "token-prefix":
        parts.extend(render_token_prefix(spec, width, height, theme))
    elif layout == "flow":
        parts.extend(render_flow(spec, width, height, theme))
    else:
        raise ValueError(f"Unsupported layout: {layout}")
    parts.append("</svg>")
    return "\n".join(parts)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec", type=Path, required=True)
    parser.add_argument("--svg", type=Path, required=True)
    parser.add_argument("--png", type=Path)
    args = parser.parse_args()
    spec = json.loads(args.spec.read_text(encoding="utf-8"))
    svg = render(spec)
    args.svg.parent.mkdir(parents=True, exist_ok=True)
    args.svg.write_text(svg, encoding="utf-8")
    if args.png:
        args.png.parent.mkdir(parents=True, exist_ok=True)
        render_png(args.svg, args.png, int(spec.get("width", 1600)), int(spec.get("height", 1000)))
    print(json.dumps({"svg": str(args.svg), "png": str(args.png) if args.png else None, "layout": spec.get("layout")}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
