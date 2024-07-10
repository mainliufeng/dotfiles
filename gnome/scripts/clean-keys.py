#!/usr/bin/env python3

import re
import subprocess
from subprocess import run

superKeyRegex = re.compile(r'["\']<Super>.+["\']')

def getKeys():
    data = run("gsettings list-recursively", capture_output=True, shell=True)
    output = data.stdout.splitlines()
    
    for line in output:
        line = line.decode('utf-8')
        splits = line.split(" ")
        if len(splits) == 4:
            yield (splits[0], splits[1], splits[2], splits[3])
        elif len(splits) == 3:
            yield (splits[0], splits[1], splits[2], "")

for key in getKeys():
    if key[0] == 'org.gnome.desktop.wm.keybindings':
        subprocess.call(["gsettings", "set", key[0], key[1], "[]"])
    if superKeyRegex.search(key[2]):
        subprocess.call(["gsettings", "set", key[0], key[1], "[]"])
