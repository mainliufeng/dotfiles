#!/usr/bin/env python3

from __future__ import annotations

import importlib.util
import json
import unittest
import xml.etree.ElementTree as ET
from pathlib import Path


SKILL_DIR = Path(__file__).resolve().parent.parent
RENDERER_PATH = SKILL_DIR / "scripts" / "render_diagram.py"
SPEC = importlib.util.spec_from_file_location("render_diagram", RENDERER_PATH)
renderer = importlib.util.module_from_spec(SPEC)
assert SPEC.loader is not None
SPEC.loader.exec_module(renderer)


class DiagramRendererTests(unittest.TestCase):
    def test_all_json_examples_render_as_svg(self) -> None:
        for path in sorted((SKILL_DIR / "assets" / "examples").glob("*.json")):
            with self.subTest(path=path.name):
                spec = json.loads(path.read_text(encoding="utf-8"))
                svg = renderer.render(spec)
                root = ET.fromstring(svg)
                self.assertEqual(root.tag, "{http://www.w3.org/2000/svg}svg")
                self.assertEqual(root.attrib["width"], str(spec["width"]))
                self.assertEqual(root.attrib["height"], str(spec["height"]))

    def test_flow_edges_keep_port_metadata_and_markers(self) -> None:
        path = SKILL_DIR / "assets" / "examples" / "flow-agent-loop.json"
        svg = renderer.render(json.loads(path.read_text(encoding="utf-8")))
        root = ET.fromstring(svg)
        edges = root.findall(".//{http://www.w3.org/2000/svg}path[@data-edge-id]")
        self.assertEqual(len(edges), 7)
        for edge in edges:
            self.assertIn("data-from", edge.attrib)
            self.assertIn("data-to", edge.attrib)
            self.assertIn("data-to-side", edge.attrib)
            self.assertIn("data-pre-end", edge.attrib)
            self.assertTrue(edge.attrib["marker-end"].startswith("url(#arrow-"))

    def test_colored_edge_uses_matching_marker(self) -> None:
        path = SKILL_DIR / "assets" / "examples" / "flow-agent-loop.json"
        svg = renderer.render(json.loads(path.read_text(encoding="utf-8")))
        root = ET.fromstring(svg)
        done_edge = root.find(".//{http://www.w3.org/2000/svg}path[@data-edge-id='decision-done']")
        self.assertIsNotNone(done_edge)
        self.assertEqual(done_edge.attrib["stroke"], renderer.DEFAULT_THEME["coral"])
        self.assertEqual(done_edge.attrib["marker-end"], "url(#arrow-coral)")

    def test_non_flow_templates_keep_attached_markers(self) -> None:
        expected = {
            "hub-spoke-agent-runtime.json": 8,
            "comparison-transport.json": 3,
            "token-prefix-cache.json": 1,
        }
        for filename, marker_count in expected.items():
            with self.subTest(filename=filename):
                path = SKILL_DIR / "assets" / "examples" / filename
                svg = renderer.render(json.loads(path.read_text(encoding="utf-8")))
                root = ET.fromstring(svg)
                paths = [
                    item
                    for item in root.findall(".//{http://www.w3.org/2000/svg}path")
                    if "marker-end" in item.attrib
                ]
                self.assertEqual(len(paths), marker_count)
                for item in paths:
                    self.assertTrue(item.attrib["marker-end"].startswith("url(#arrow-"))


if __name__ == "__main__":
    unittest.main()
