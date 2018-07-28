import sys
import os
import yaml
import shutil


def install_by_config(config_path, need_confirm=True):
    with open(config_path, 'r') as config_file:
        apps = yaml.load(config_file)
        if not apps:
            return
        for app in apps:
            confirm = app.get('confirm')
            name = app.get('name')
            which = app.get('which')
            brew = app.get('brew')
            pip = app.get('pip')
            cmd = app.get('cmd')

            if not cmd:
                if brew: cmd = 'brew install ' + brew
                elif pip: cmd = 'pip install ' + pip
            if not which:
                if brew: which = brew
                elif pip: which = pip
            if not name:
                if brew: name = brew
                elif pip: name = pip
                elif which: name = which
            if not confirm:
                if name: confirm = 'install ' + name

            if need_confirm and not get_confirm(confirm):
                continue
            else:
                print(confirm)

            if which and shutil.which(which):
                print('skip, ' + which + ' exists')
                continue

            os.system(cmd)


def get_confirm(question, default="yes"):
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
