#!/usr/bin/env python

import os
import sys
import subprocess

from importlib.machinery import SourceFileLoader

dotfiles_path = os.path.join(os.environ['HOME'], 'dotfiles')
common_prompt_path = os.path.join(dotfiles_path, 'common', 'prompt.py')
prompt = SourceFileLoader('prompt', common_prompt_path).load_module()


GIT_GET_BRANCH_CMD = 'git symbolic-ref HEAD 2> /dev/null'
GIT_INSIDE_WORK_TREE_CMD = 'git rev-parse --is-inside-work-tree >/dev/null 2>&1'
GIT_BRANCH_ICON = '  '
GIT_HASH_ICON = ' ➦ '
GIT_GET_SHORT_HASH_CMD = 'git show-ref --head -s --abbrev |head -n1 2> /dev/null'
DISABLE_UNTRACKED_FILES_DIRTY = False
PROMPT_DIRTY = '±'
PROMPT_CLEAN = ''
GIT_CHECK_DIRTY_CMD = 'git status {} 2> /dev/null'


def git_prompt():
    if os.system(GIT_INSIDE_WORK_TREE_CMD) == 0:
        ref = os.popen(GIT_GET_BRANCH_CMD).read().strip()
        if ref:
            ref = ref.replace('refs/heads/', '')
            ref = GIT_BRANCH_ICON + ref
        else:
            ref = GIT_HASH_ICON + os.popen(GIT_GET_SHORT_HASH_CMD).read()
        if _git_is_dirty():
            return prompt.Segment(text=ref + PROMPT_DIRTY, bg='yellow', fg='black')
        else:
            return prompt.Segment(text=ref + PROMPT_CLEAN, bg='green', fg='black')


def _git_is_dirty():
    flags = '--porcelain'
    if DISABLE_UNTRACKED_FILES_DIRTY:
        flags += ' --untracked-files=no'
    cmd = GIT_CHECK_DIRTY_CMD.format(flags)
    return os.popen(cmd).read().strip()


def status_prompt():
    return prompt.Segment(text=' ✝ ', bg='black', fg='gray')


def dir_prompt():
    return prompt.Segment(text=' %3~ ', bg='blue', fg='black')


def pyenv_prompt():
    py_version = os.popen('pyenv version-name').read().strip()
    if py_version:
        return prompt.Segment(text=py_version, bg='green', fg='black')


def pipenv_prompt():
    venv = os.popen('pipenv --venv 2> /dev/null').read().strip()
    if venv:
        venv = ' ' + venv.split('/')[-1]
        return prompt.Segment(text=venv, bg='red', fg='black')


def main():
    prompt_funcs = [
        status_prompt,
        dir_prompt,
        pyenv_prompt,
        pipenv_prompt,
        git_prompt
    ]

    segments = []
    for prompt_func in prompt_funcs:
        segment = prompt_func()
        if segment:
            segments.append(segment)

    print(prompt.gen_prompt(segments))


if __name__ == '__main__':
    main()
