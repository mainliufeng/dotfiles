import os
from collections import namedtuple


Segment = namedtuple('Segment', ['text', 'fg', 'bg'])
segment_seperator = ''


def gen_start(bg):
    return '%{%K{' + bg + '}%}%{%F{default}%}'


def gen_end():
    return ' %{%f%}%'


def gen_segment(fg, text):
    return '%{%F{' + fg + '}%}' + text


def gen_sep(fg, bg):
    if bg:
        return '%{%K{' + bg + '}%F{' + fg + '}%}' + segment_seperator
    else:
        return ' %{%k%F{' + fg + '}%}' + segment_seperator


def gen_prompt(segments):
    ret = []
    ret.append(gen_start(segments[0].bg))
    for index, segment in enumerate(segments):
        ret.append(gen_segment(segment.fg, segment.text))
        if index < len(segments) - 1:
            ret.append(gen_sep(segment.bg, segments[index+1].bg))
        else:
            ret.append(gen_sep(segment.bg, None))
    ret.append(gen_end())
    return ''.join(ret)
