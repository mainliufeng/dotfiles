#!/usr/bin/env python3
"""Validate structural invariants of generated SVG/PNG technical diagrams."""

from __future__ import annotations

import argparse
import json
import math
import struct
import xml.etree.ElementTree as ET
from pathlib import Path


SVG_NS = {"svg": "http://www.w3.org/2000/svg"}
ARROW_GLYPHS = {"→", "←", "↑", "↓", "↔", "↕", "▶", "◀", "▲", "▼"}


def pair(value: str) -> tuple[float, float]:
    a, b = value.split(",")
    return float(a), float(b)


def bbox(value: str) -> tuple[float, float, float, float]:
    a, b, c, d = value.split(",")
    return float(a), float(b), float(c), float(d)


def expected_port(box: tuple[float, float, float, float], side: str) -> tuple[float, float]:
    x, y, w, h = box
    return {
        "left": (x, y + h / 2),
        "right": (x + w, y + h / 2),
        "top": (x + w / 2, y),
        "bottom": (x + w / 2, y + h),
    }[side]


def png_dimensions(path: Path) -> tuple[int, int]:
    with path.open("rb") as handle:
        header = handle.read(24)
    if header[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("not a PNG")
    return struct.unpack(">II", header[16:24])


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--spec", type=Path, required=True)
    parser.add_argument("--svg", type=Path, required=True)
    parser.add_argument("--png", type=Path)
    args = parser.parse_args()
    spec = json.loads(args.spec.read_text(encoding="utf-8"))
    errors: list[str] = []
    warnings: list[str] = []
    root = ET.parse(args.svg).getroot()
    width, height = int(float(root.attrib["width"])), int(float(root.attrib["height"]))
    if (width, height) != (int(spec.get("width", width)), int(spec.get("height", height))):
        errors.append("SVG dimensions do not match the specification")

    # Accessibility contract: role=img + title as first child + accessible name.
    if root.attrib.get("role") != "img":
        errors.append("SVG root must carry role=\"img\"")
    svg_children = list(root)
    title_first = bool(svg_children) and svg_children[0].tag == f"{{{SVG_NS['svg']}}}title"
    if not title_first:
        warnings.append("SVG has no <title> as its first child; screen readers may miss the name")
    has_name = root.attrib.get("aria-label") is not None or any(
        el.tag == f"{{{SVG_NS['svg']}}}title" for el in root.iter()
    )
    if not has_name:
        warnings.append("SVG has no accessible name (aria-label or <title>)")

    # 4px grid: declared box geometry and font sizes must be multiples of 4.
    off_grid: list[str] = []
    for element in root.iter():
        tag = element.tag.split("}")[-1]
        for attr in ("x", "y", "width", "height"):
            if tag == "rect" and attr in element.attrib:
                try:
                    value = float(element.attrib[attr])
                except ValueError:
                    continue
                if value % 4 != 0:
                    off_grid.append(f"rect {attr}={element.attrib[attr]}")
        if tag == "text" and "font-size" in element.attrib:
            try:
                value = float(element.attrib["font-size"])
            except ValueError:
                continue
            if value % 4 != 0:
                off_grid.append(f"text font-size={element.attrib['font-size']}")
    if off_grid:
        shown = ", ".join(off_grid[:12])
        suffix = " …" if len(off_grid) > 12 else ""
        warnings.append(f"off-grid values (boxes and font sizes must be multiples of 4): {shown}{suffix}")

    nodes = {}

    marker_lengths: dict[str, float] = {}
    for marker in root.findall(".//svg:marker", SVG_NS):
        marker_id = marker.attrib.get("id", "<unnamed>")
        if marker.attrib.get("markerUnits") != "userSpaceOnUse":
            errors.append(f"{marker_id}: markerUnits must be userSpaceOnUse")
        try:
            marker_lengths[marker_id] = float(marker.attrib.get("markerWidth", "0"))
        except ValueError:
            errors.append(f"{marker_id}: markerWidth is not numeric")

    for text in root.findall(".//svg:text", SVG_NS):
        value = "".join(text.itertext()).strip()
        if value in ARROW_GLYPHS:
            errors.append(f"topology connector uses a Unicode arrow glyph: {value}")

    for group in root.findall(".//svg:g[@data-node-id]", SVG_NS):
        nodes[group.attrib["data-node-id"]] = bbox(group.attrib["data-bbox"])
    edges = root.findall(".//svg:path[@data-edge-id]", SVG_NS)
    for edge in edges:
        edge_id = edge.attrib["data-edge-id"]
        if "marker-end" not in edge.attrib:
            errors.append(f"{edge_id}: missing marker-end")
        source = edge.attrib.get("data-from", "")
        target = edge.attrib.get("data-to", "")
        if source not in nodes:
            errors.append(f"{edge_id}: unknown source node {source}")
        if target not in nodes:
            errors.append(f"{edge_id}: unknown target node {target}")
            continue
        end = pair(edge.attrib["data-end"])
        pre_end = pair(edge.attrib["data-pre-end"])
        expected = expected_port(nodes[target], edge.attrib["data-to-side"])
        if math.dist(end, expected) > 1.1:
            errors.append(f"{edge_id}: arrow endpoint {end} is detached from target port {expected}")
        to_side = edge.attrib["data-to-side"]
        approaches_from_outside = {
            "left": pre_end[0] < end[0],
            "right": pre_end[0] > end[0],
            "top": pre_end[1] < end[1],
            "bottom": pre_end[1] > end[1],
        }[to_side]
        if not approaches_from_outside:
            errors.append(f"{edge_id}: final segment approaches the {to_side} port from inside the target node")
        marker_ref = edge.attrib.get("marker-end", "")
        marker_id = marker_ref.removeprefix("url(#").removesuffix(")")
        marker_length = marker_lengths.get(marker_id, 16.0)
        final_segment = math.dist(pre_end, end)
        if final_segment < marker_length * 1.5:
            errors.append(
                f"{edge_id}: final shaft {final_segment:.1f}px is shorter than "
                f"1.5x arrowhead length {marker_length:.1f}px"
            )
    text_sizes = []
    for text in root.findall(".//svg:text", SVG_NS):
        if "font-size" in text.attrib:
            text_sizes.append(float(text.attrib["font-size"]))
    if text_sizes:
        mobile_min = min(text_sizes) * 390 / width
        if mobile_min < 7.5:
            warnings.append(f"smallest text scales to {mobile_min:.1f}px at 390px width; inspect mobile preview")
    if args.png:
        try:
            png_size = png_dimensions(args.png)
            if png_size != (width, height):
                errors.append(f"PNG dimensions {png_size} do not match SVG {(width, height)}")
        except (OSError, ValueError) as exc:
            errors.append(f"PNG validation failed: {exc}")

    # Complexity budget: plan-level gate, reported as warnings.
    if len(nodes) > 9:
        warnings.append(f"complexity budget: {len(nodes)} nodes exceed the 9-node limit; split into overview + detail")
    if len(edges) > 12:
        warnings.append(f"complexity budget: {len(edges)} arrows exceed the 12-arrow limit; split into overview + detail")

    result = {
        "valid": not errors,
        "layout": spec.get("layout"),
        "nodes": len(nodes),
        "edges": len(edges),
        "errors": errors,
        "warnings": warnings,
    }
    print(json.dumps(result, ensure_ascii=False, indent=2))
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
