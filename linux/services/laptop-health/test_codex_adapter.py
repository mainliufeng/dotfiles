import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

spec = importlib.util.spec_from_file_location("codex_adapter", Path(__file__).with_name("codex_adapter.py"))
adapter = importlib.util.module_from_spec(spec)
spec.loader.exec_module(adapter)


class CodexAdapterTest(unittest.TestCase):
    def test_fail_closed_without_process_or_network(self):
        with tempfile.TemporaryDirectory() as root:
            base = Path(root)
            evidence = base / "evidence.json"
            evidence.write_text(json.dumps({"secret": "do-not-output-this"}))
            with patch("subprocess.Popen", side_effect=AssertionError("must not spawn")), patch("socket.socket", side_effect=AssertionError("must not connect")):
                result = adapter.diagnose(evidence, base / "run")
            self.assertFalse(result["enabled"])
            self.assertFalse(result["transmitted"])
            self.assertFalse(result["model_invoked"])
            output = base / "run/diagnosis.json"
            self.assertNotIn("do-not-output-this", output.read_text())
            self.assertEqual(output.stat().st_mode & 0o777, 0o600)
            self.assertEqual(output.parent.stat().st_mode & 0o777, 0o700)

    def test_reject_bad_json_and_oversize(self):
        with tempfile.TemporaryDirectory() as root:
            p = Path(root) / "input"
            for content in ("not json", "[]", "x" * (adapter.MAX_EVIDENCE_BYTES + 1)):
                p.write_text(content)
                with self.assertRaises(ValueError):
                    adapter.diagnose(p, Path(root) / "run")

    def test_reject_symlink_evidence(self):
        with tempfile.TemporaryDirectory() as root:
            base = Path(root)
            (base / "file").write_text("{}")
            (base / "link").symlink_to(base / "file")
            with self.assertRaises(OSError):
                adapter.diagnose(base / "link", base / "run")

    def test_reject_existing_result(self):
        with tempfile.TemporaryDirectory() as root:
            base = Path(root)
            (base / "input").write_text("{}")
            adapter.diagnose(base / "input", base / "run")
            with self.assertRaises(FileExistsError):
                adapter.diagnose(base / "input", base / "run")

    def test_reject_public_output_dir(self):
        with tempfile.TemporaryDirectory() as root:
            base = Path(root)
            (base / "input").write_text("{}")
            (base / "run").mkdir(mode=0o755)
            with self.assertRaises(ValueError):
                adapter.diagnose(base / "input", base / "run")


if __name__ == "__main__":
    unittest.main()
