from __future__ import annotations

import importlib.util
import sys
import tempfile
import unittest
from importlib.machinery import SourceFileLoader
from pathlib import Path
from unittest.mock import patch


SCRIPT = Path(__file__).resolve().parents[1] / "bin/skill-manager"
LOADER = SourceFileLoader("agent_skill_manager_script", str(SCRIPT))
SPEC = importlib.util.spec_from_loader(LOADER.name, LOADER)
assert SPEC is not None
SKILL_MANAGER = importlib.util.module_from_spec(SPEC)
sys.modules[SPEC.name] = SKILL_MANAGER
LOADER.exec_module(SKILL_MANAGER)


class HermesCategoryMigrationTest(unittest.TestCase):
    def test_moves_only_managed_install_from_old_category(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            source = root / "library/dbs-example"
            source.mkdir(parents=True)
            (source / "SKILL.md").write_text("# managed\n")

            hermes_root = root / "hermes"
            stale = hermes_root / "local/dbs-example"
            stale.mkdir(parents=True)
            (stale / "SKILL.md").symlink_to(source / "SKILL.md")

            custom_source = root / "custom/SKILL.md"
            custom_source.parent.mkdir(parents=True)
            custom_source.write_text("# custom\n")
            custom = hermes_root / "custom/dbs-example"
            custom.mkdir(parents=True)
            (custom / "SKILL.md").symlink_to(custom_source)

            original_root = SKILL_MANAGER.HERMES_ROOT
            SKILL_MANAGER.HERMES_ROOT = hermes_root
            self.addCleanup(setattr, SKILL_MANAGER, "HERMES_ROOT", original_root)

            runner = SKILL_MANAGER.Runner(dry_run=False)
            SKILL_MANAGER.install_hermes_skill(
                "dbs-example", source, source, "workflow-infrastructure", runner
            )

            installed = hermes_root / "workflow-infrastructure/dbs-example"
            self.assertFalse(stale.exists())
            self.assertTrue(custom.exists())
            self.assertTrue(installed.is_dir())
            self.assertFalse(installed.is_symlink())
            self.assertEqual(
                (installed / "SKILL.md").resolve(), (source / "SKILL.md").resolve()
            )

    def test_removes_deleted_bundle_child_from_library_and_hermes(self) -> None:
        with tempfile.TemporaryDirectory() as temp_dir:
            root = Path(temp_dir)
            source = root / "source/dbskill"
            current = source / "skills/dbs-current"
            current.mkdir(parents=True)
            (current / "SKILL.md").write_text("# current\n")

            library_root = root / "library"
            library_root.mkdir()
            deleted_link = library_root / "dbs-deleted"
            deleted_link.symlink_to(source / "skills/dbs-deleted")

            hermes_root = root / "hermes"
            stale = hermes_root / "local/dbs-deleted"
            stale.mkdir(parents=True)
            (stale / "SKILL.md").symlink_to(deleted_link / "SKILL.md")

            custom_source = root / "custom/dbs-custom"
            custom_source.mkdir(parents=True)
            (custom_source / "SKILL.md").write_text("# custom\n")
            custom_link = library_root / "dbs-custom"
            custom_link.symlink_to(custom_source)
            custom = hermes_root / "local/dbs-custom"
            custom.mkdir(parents=True)
            (custom / "SKILL.md").symlink_to(custom_link / "SKILL.md")

            entry = SKILL_MANAGER.Entry(
                id="dbskill",
                adapter="bundle_children",
                source_path=source,
                codex="active",
                hermes="active",
                pi="active",
                hermes_category="",
                platforms="all",
                clone_url="",
                notes="",
                registry=root / "registry.tsv",
            )
            runner = SKILL_MANAGER.Runner(dry_run=False)
            with (
                patch.object(SKILL_MANAGER, "LIBRARY_ROOT", library_root),
                patch.object(SKILL_MANAGER, "HERMES_ROOT", hermes_root),
            ):
                SKILL_MANAGER.sync([entry], {"hermes"}, "dbskill", runner)

            self.assertFalse(deleted_link.exists())
            self.assertFalse(deleted_link.is_symlink())
            self.assertFalse(stale.exists())
            self.assertTrue(custom.exists())
            self.assertTrue(custom_link.is_symlink())
            self.assertTrue((hermes_root / "local/dbs-current/SKILL.md").exists())


if __name__ == "__main__":
    unittest.main()
