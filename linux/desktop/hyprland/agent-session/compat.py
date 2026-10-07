"""Translate this desktop's existing human commands to the fork's Lua API."""
import json
import re


def lua(value):
    if isinstance(value, dict):
        return '{' + ','.join('[' + lua(k) + ']=' + lua(v) for k, v in value.items()) + '}'
    if isinstance(value, (list, tuple)):
        return '{' + ','.join(map(lua, value)) + '}'
    return json.dumps(value, ensure_ascii=False)


def value(text):
    text = text.strip()
    if text in ('true', 'yes', 'on'): return True
    if text in ('false', 'no', 'off'): return False
    if re.fullmatch(r'-?\d+', text): return int(text)
    if re.fullmatch(r'-?\d*\.\d+', text): return float(text)
    if 'deg' in text and text.startswith(('rgba(', 'rgb(')):
        colors = text.split()
        return {'colors': colors[:-1], 'angle': float(colors[-1][:-3])}
    return text


def dispatch(name, argument=''):
    argument = argument.strip()
    def call(path, params=None):
        return 'hl.dsp.' + path + '(' + ('' if params is None else lua(params)) + ')'
    simple = {'killactive': 'window.close', 'exit': 'exit', 'forcerendererreload': 'force_renderer_reload',
              'togglefloating': 'window.float', 'togglegroup': 'group.toggle', 'pin': 'window.pin',
              'centerwindow': 'window.center', 'movewindow': 'window.drag', 'resizewindow': 'window.resize',
              'focuscurrentorlast': 'focus'}
    if name == 'focuscurrentorlast': return call('focus', {'last': True})
    if name in simple: return call(simple[name])
    if name in ('workspace', 'focusworkspaceoncurrentmonitor'):
        p = {'workspace': argument}
        if name != 'workspace': p['on_current_monitor'] = True
        return call('focus', p)
    if name == 'focuswindow': return call('focus', {'window': argument})
    if name == 'focusmonitor': return call('focus', {'monitor': argument})
    if name == 'movefocus': return call('focus', {'direction': {'l':'left','r':'right','u':'up','d':'down'}.get(argument, argument)})
    if name in ('exec', 'execr'): return call('exec_cmd' if name == 'exec' else 'exec_raw', argument)
    if name == 'layoutmsg': return call('layout', argument)
    if name == 'fullscreen': return call('window.fullscreen', {'mode': 'maximized' if argument == '1' else 'fullscreen'})
    if name == 'fullscreenstate':
        args = argument.split()
        return call('window.fullscreen_state', {'internal': int(args[0]), 'client': int(args[1]), 'action': args[2] if len(args)>2 else 'set'})
    if name == 'changegroupactive': return call('group.prev' if argument == 'b' else 'group.next')
    if name in ('lockgroups', 'lockactivegroup'):
        return call('group.lock' if name == 'lockgroups' else 'group.lock_active', {'action': argument})
    if name in ('movetoworkspace', 'movetoworkspacesilent'):
        parts = argument.split(',', 1); p = {'workspace': parts[0], 'silent': name.endswith('silent')}
        if len(parts)>1: p['window'] = parts[1]
        return call('window.move', p)
    if name == 'movecurrentworkspacetomonitor': return call('workspace.move', {'monitor': argument})
    if name == 'togglespecialworkspace': return call('workspace.toggle_special', argument or '')
    if name == 'resizeactive':
        parts = argument.split(); exact = parts[0] == 'exact'
        if exact: parts = parts[1:]
        return call('window.resize', {'x': float(parts[0]), 'y': float(parts[1]), 'relative': not exact})
    if name == 'submap': return call('submap', argument)
    if name == 'dpms': return call('dpms', {'action': argument})
    raise ValueError('Unsupported legacy dispatcher: ' + name)
