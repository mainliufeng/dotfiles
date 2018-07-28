#!/usr/bin/env python

import sys
import os
import libtmux

def get_current_window():
    output = os.popen(
        'tmux list-windows -a -F "#{session_name} #{window_name}" ' +
        '| fzf-tmux +m --reverse --ansi').read()
    if output:
        splits = output.split()
        session_name = splits[0]
        window_name = splits[1]
        return session_name, window_name


def switch_window(session_name, window_name):
    os.popen(
        'tmux switch-client -t ' +
        '"' + session_name + '" \; ' +
        'select-window -t "' + window_name + '"')


if __name__ == '__main__':
    session_window = get_current_window()
    if session_window:
        switch_window(session_window[0], session_window[1])
