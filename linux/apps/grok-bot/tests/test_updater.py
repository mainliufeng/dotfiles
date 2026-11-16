import importlib.machinery
import importlib.util
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

SCRIPT = Path(__file__).resolve().parents[3] / 'scripts/update-grok-bot'
loader = importlib.machinery.SourceFileLoader('updater', str(SCRIPT))
spec = importlib.util.spec_from_loader(loader.name, loader)
u = importlib.util.module_from_spec(spec)
loader.exec_module(u)

class UpdaterTest(unittest.TestCase):
    def test_metadata_is_data_not_code(self):
        text = "pkgver=1.1.0\n_commit=" + 'a'*40 + "\nsha256sums=('" + 'b'*64 + "')\n" + 'https://downloads.cursor.com/grokbot/stable/${_commit}/linux/x64/grok-bot_${pkgver}_amd64.deb'
        self.assertEqual(u.candidate(text)[0], '1.1.0')
        with self.assertRaises(ValueError):
            u.candidate(text.replace('1.1.0', '$(touch /tmp/unsafe)'))
        with self.assertRaises(ValueError):
            u.candidate(text.replace('downloads.cursor.com', 'evil.example'))

    def test_activation_and_rollback(self):
        with tempfile.TemporaryDirectory() as d:
            home = Path(d); base = home / '.local/opt/grok-bot'; base.mkdir(parents=True)
            a = base/'1.1.0'; b=base/'1.2.0'; a.mkdir(); b.mkdir()
            with patch.object(u.shutil, 'which', return_value=None):
                u.activate(home, base, a)
                u.activate(home, base, b)
                self.assertEqual((base/'previous').resolve(), a)
                u.activate(home, base, (base/'previous').resolve())
                self.assertEqual((base/'current').resolve(), a)
                self.assertEqual((base/'previous').resolve(), b)

    def test_failed_validation_restores_launcher_and_pointer(self):
        with tempfile.TemporaryDirectory() as d:
            home=Path(d); base=home/'.local/opt/grok-bot';base.mkdir(parents=True)
            a=base/'1.1.0';b=base/'1.2.0';a.mkdir();b.mkdir()
            with patch.object(u.shutil, 'which', return_value=None):u.activate(home,base,a)
            launcher=home/'.local/bin/grok-bot'; old=launcher.read_bytes()
            with patch.object(u.shutil,'which',return_value='/bin/false'), patch.object(u.subprocess,'run',side_effect=RuntimeError('validation failed')):
                with self.assertRaises(RuntimeError):u.activate(home,base,b)
            self.assertEqual((base/'current').resolve(),a)
            self.assertEqual(launcher.read_bytes(),old)

    def test_directory_is_not_overwritten(self):
        with tempfile.TemporaryDirectory() as d:
            home=Path(d);base=home/'.local/opt/grok-bot';base.mkdir(parents=True)
            (base/'current').mkdir()
            with self.assertRaises(ValueError):u.activate(home,base,base/'1.1.0')

if __name__ == '__main__':unittest.main()
