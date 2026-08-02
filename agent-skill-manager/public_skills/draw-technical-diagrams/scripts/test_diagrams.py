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

    def test_arrow_markers_use_fixed_user_space_units(self) -> None:
        path = SKILL_DIR / "assets" / "examples" / "flow-agent-loop.json"
        svg = renderer.render(json.loads(path.read_text(encoding="utf-8")))
        root = ET.fromstring(svg)
        markers = root.findall(".//{http://www.w3.org/2000/svg}marker")
        self.assertGreater(len(markers), 0)
        for marker in markers:
            self.assertEqual(marker.attrib.get("markerUnits"), "userSpaceOnUse")
            self.assertLessEqual(float(marker.attrib["markerWidth"]), 20)

    def test_hub_spokes_use_nonzero_organic_curves(self) -> None:
        path = SKILL_DIR / "assets" / "examples" / "hub-spoke-agent-runtime.json"
        svg = renderer.render(json.loads(path.read_text(encoding="utf-8")))
        root = ET.fromstring(svg)
        spokes = root.findall(".//{http://www.w3.org/2000/svg}path[@data-route='organic-cubic']")
        self.assertEqual(len(spokes), 8)
        for spoke in spokes:
            self.assertIn(" C", spoke.attrib["d"])
            self.assertNotEqual(float(spoke.attrib["data-curve"]), 0.0)

    def test_annotated_hub_has_independent_visuals_and_curved_routes(self) -> None:
        path = SKILL_DIR / "assets" / "examples" / "annotated-hub-agent-optimizations.json"
        svg = renderer.render(json.loads(path.read_text(encoding="utf-8")))
        root = ET.fromstring(svg)
        callouts = root.findall(".//{http://www.w3.org/2000/svg}g[@data-node-id]")
        visuals = root.findall(".//{http://www.w3.org/2000/svg}g[@data-mini-visual]")
        routes = root.findall(".//{http://www.w3.org/2000/svg}path[@data-route='annotated-cubic']")
        sectors = root.findall(".//{http://www.w3.org/2000/svg}path[@data-wheel-id]")
        self.assertEqual(len(callouts), 9)
        self.assertEqual(len(visuals), 9)
        self.assertEqual(len(routes), 9)
        self.assertEqual(len(sectors), 9)
        self.assertTrue(all(" C" in route.attrib["d"] for route in routes))
        route_colors = {route.attrib["data-item-id"]: route.attrib["stroke"] for route in routes}
        sector_colors = {sector.attrib["data-wheel-id"]: sector.attrib["fill"] for sector in sectors}
        self.assertEqual(route_colors, sector_colors)

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
