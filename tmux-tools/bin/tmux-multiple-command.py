#!/usr/bin/env python

import sys
import os
import libtmux


def current_session():
    server = libtmux.Server()
    session_name = os.popen('tmux display-message -p "#S"').read().strip()
    session = server.find_where({"session_name": session_name})
    return session


def current_pane():
    session = current_session()
    window = session.attached_window
    pane = window.attached_pane
    return pane


def run_commands(commands):
    pane = current_pane()
    for command in commands:
        pane.send_keys(command)


def get_pane_output(pane):
    return '\n'.join(pane.cmd('capture-pane', '-p').stdout)


if __name__ == '__main__':
    run_commands(sys.argv[1:])
