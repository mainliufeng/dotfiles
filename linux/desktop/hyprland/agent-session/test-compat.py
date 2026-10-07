"""Pure legacy-to-Lua translation checks; sends no desktop input."""
import unittest
from compat import dispatch

class Shortcuts(unittest.TestCase):
    def test_application_paste(self):
        self.assertEqual(dispatch('sendshortcut', 'CTRL, V, address:0x123'), 'hl.dsp.send_shortcut({["mods"]="CTRL",["key"]="V",["window"]="address:0x123"})')
    def test_terminal_paste(self):
        self.assertEqual(dispatch('sendshortcut', 'CTRL SHIFT, V, address:0x456'), 'hl.dsp.send_shortcut({["mods"]="CTRL SHIFT",["key"]="V",["window"]="address:0x456"})')
    def test_current_window(self):
        self.assertEqual(dispatch('sendshortcut', 'CTRL, V,'), 'hl.dsp.send_shortcut({["mods"]="CTRL",["key"]="V"})')
    def test_quoted_window(self):
        self.assertIn('title:^a\\"b, c$', dispatch('sendshortcut', 'CTRL, V, title:^a"b, c$'))
    def test_invalid(self):
        for value in ('CTRL', 'CTRL, , address:0x1'):
            with self.assertRaises(ValueError): dispatch('sendshortcut', value)

if __name__ == '__main__': unittest.main()
