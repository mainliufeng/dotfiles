#!/usr/bin/python3
"""Generate a separate Lua config; never edit the original hyprlang config."""
import pathlib
import re
import sys
from compat import dispatch, lua, value

variables = {}
settings, commands, binds = {}, [], []
rules, animations, curves, gestures = [], [], [], []
submap = None
seen = set()


def expand(text):
    for key, val in variables.items(): text = text.replace('$' + key, val)
    return text


def read(path):
    global submap
    path = path.expanduser().resolve()
    if path in seen: raise ValueError('Repeated source: ' + str(path))
    seen.add(path)
    sections = []
    for number, raw in enumerate(path.read_text().splitlines(), 1):
        text = raw.split('#', 1)[0].strip()
        if not text: continue
        if text == '}': sections.pop(); continue
        if text.endswith('{'): sections.append(text[:-1].strip()); continue
        if '=' not in text: raise ValueError(f'{path}:{number}: unsupported line: {text}')
        key, val = [x.strip() for x in text.split('=', 1)]
        if key.startswith('$'): variables[key[1:]] = val; continue
        val = expand(val)
        if key == 'source': read(pathlib.Path(val)); continue
        if key == 'submap': submap = None if val == 'reset' else val; continue
        if key.startswith('bind'):
            parts = [x.strip() for x in val.split(',', 3)]
            while len(parts)<4: parts.append('')
            mods, sym, action, arg = parts
            chord = ' + '.join(mods.split() + [sym])
            flags = {flag:True for code,flag in [('r','release'),('e','repeating'),('l','locked'),('m','mouse')] if code in key[4:]}
            binds.append((submap, f'hl.bind({lua(chord)}, {dispatch(action,arg)}, {lua(flags)})'))
        elif key == 'exec-once': commands.append(val)
        elif key == 'env':
            name, v = val.split(',', 1); rules.append('hl.env('+lua(name.strip())+','+lua(v.strip())+')')
        elif key == 'monitor':
            output, mode, position, scale = [x.strip() for x in val.split(',')]
            rules.append('hl.monitor('+lua({'output':output,'mode':mode,'position':position,'scale':value(scale)})+')')
        elif key in ('windowrule','layerrule'):
            parts = [x.strip() for x in val.split(',')]; effect, arg = parts[0].split(' ', 1)
            rule={'name':'native-migrated-'+str(len(rules)), 'match':{}}
            for part in parts[1:]:
                field, match = part.split(' ', 1); rule['match'][field.removeprefix('match:')] = match
            rule[effect] = value(arg)
            rules.append(('hl.window_rule' if key=='windowrule' else 'hl.layer_rule')+'('+lua(rule)+')')
        elif key == 'bezier':
            args = [x.strip() for x in val.split(',')]
            curves.append('hl.curve('+lua(args[0])+','+lua({'type':'bezier','points':[[float(args[1]),float(args[2])],[float(args[3]),float(args[4])]]})+')')
        elif key == 'animation':
            args = [x.strip() for x in val.split(',')]
            p={'leaf':args[0],'enabled':args[1]=='1','speed':float(args[2]),'bezier':args[3]}
            if len(args)>4: p['style']=args[4]
            animations.append('hl.animation('+lua(p)+')')
        elif key == 'gesture':
            parts=[x.strip() for x in val.split(',')]
            gestures.append('hl.gesture('+lua({'fingers':int(parts[0]),'direction':parts[1],'action':parts[2]})+')')
            for part in parts[3:]:
                k,v=part.split(':',1)
                settings['gestures.workspace_swipe_'+k]=value(v)
        elif sections:
            settings['.'.join(sections+[key.replace('-', '_')])] = value(val)
        else: raise ValueError(f'{path}:{number}: unsupported key: {key}')


read(pathlib.Path(sys.argv[1]))
out=['-- Generated from the existing config and its sources. Original files are preserved.',
     'hl.config('+lua(settings)+')', *curves, *animations, *rules, *gestures]
out += [line for group,line in binds if group is None]
for group in dict.fromkeys(group for group,line in binds if group):
    out += ['hl.define_submap('+lua(group)+',function()', *[line for g,line in binds if g==group], 'end)']
out += ['if os.getenv("CORNICE_SESSION_TEST") ~= "1" then', 'hl.on("hyprland.start",function()']
# Start Cornice after all three seat globals exist, then start the usual apps.
out += ['hl.exec_cmd(os.getenv("HOME") .. "/dotfiles/linux/desktop/hyprland/agent-session/session-start")', 'end)', 'end']
pathlib.Path(sys.argv[2]).write_text('\n'.join(out)+'\n')
pathlib.Path(sys.argv[2]).with_suffix('.autostart.json').write_text(__import__('json').dumps(commands,ensure_ascii=False,indent=2)+'\n')
print(f'Converted {len(settings)} settings, {len(binds)} bindings, {len(rules)} rules/env/monitor declarations and {len(commands)} startup commands')
