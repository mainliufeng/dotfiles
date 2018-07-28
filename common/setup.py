import sys
import os
from shutil import which
from collections import namedtuple


App = namedtuple('App', ['command', 'platform_install_commands'])
Apps = namedtuple('Apps', ['note', 'apps'])


def sh_install(note, install_commands, need_confirm, command=None):
    install(Apps(note=note, apps=[
        App(command=command, platform_install_commands={
            'darwin': install_commands
        }),
    ]), need_confirm)


def pip_install_path(name, path, need_confirm, command=None):
    install(Apps(note='install {}'.format(name), apps=[
        App(command=command if command else name, platform_install_commands={
            'darwin': ['pip install -e {}'.format(path)]
        }),
    ]), need_confirm)


def pip_install(name, need_confirm, command=None):
    install(Apps(note='install {}'.format(name), apps=[
        App(command=command if command else name, platform_install_commands={
            'darwin': ['pip install {}'.format(name)]
        }),
    ]), need_confirm)


def brew_install(name, need_confirm, command=None):
    install(Apps(note='install {}'.format(name), apps=[
        App(command=command if command else name, platform_install_commands={
            'darwin': ['brew install {}'.format(name)]
        }),
    ]), need_confirm)


def install(apps, need_confirm):
    if need_confirm and not confirm(apps.note):
        return
    for app in apps.apps:
        if app.command and exists(app.command):
            print('skip, {} exists'.format(app.command))
            continue
        install_commands = app.platform_install_commands[sys.platform]
        if not install_commands:
            print('skip, os is {}'.format(sys.platform))
        for install_command in install_commands:
            print(install_command)
            os.system(install_command)


def exists(command):
    return which(command) is not None


def confirm(question, default="yes"):
    valid = {"yes": True, "y": True, "ye": True,
             "no": False, "n": False}
    if default is None:
        prompt = " [y/n] "
    elif default == "yes":
        prompt = " [Y/n] "
    elif default == "no":
        prompt = " [y/N] "
    else:
        raise ValueError("invalid default answer: '%s'" % default)

    while True:
        sys.stdout.write(question + prompt)
        choice = input().lower()
        if default is not None and choice == '':
            return valid[default]
        elif choice in valid:
            return valid[choice]
        else:
            sys.stdout.write("Please respond with 'yes' or 'no' "
                             "(or 'y' or 'n').\n")
