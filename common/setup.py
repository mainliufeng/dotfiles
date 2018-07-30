import sys
import os
import yaml
import shutil


dotfiles_path = os.path.join(os.environ['HOME'], 'dotfiles')


def list_apps():
    apps = []
    for app in os.listdir(dotfiles_path):
        if os.path.isfile(setup_config_path(app)):
            apps.append(app)
    return apps


def install_app(app, need_confirm=True):
    install_by_config(app, need_confirm)


def setup_config_path(app):
    return os.path.join(dotfiles_path, app, 'setup.yaml')


def install_by_config(app, need_confirm=True):
    config_path = setup_config_path(app)
    with open(config_path, 'r') as config_file:
        app_configs = yaml.load(config_file)
        if not app_configs:
            return
        for app_config in app_configs:
            confirm = app_config.get('confirm')
            name = app_config.get('name')
            which = app_config.get('which')
            brew = app_config.get('brew')
            pip = app_config.get('pip')
            cask = app_config.get('cask')
            cmd = app_config.get('cmd')
            symlink = app_config.get('symlink')
            show = app_config.get('show')

            if not cmd:
                if brew: cmd = 'brew install ' + brew
                elif cask: cmd = 'brew cask install ' + cask
                elif pip: cmd = 'pip install ' + pip
            if not which:
                if brew: which = brew
                elif pip: which = pip
            if not name:
                if brew: name = brew
                elif pip: name = pip
                elif which: name = which
                elif app: name = app
            if not confirm:
                if name: confirm = 'install ' + name

            if cmd and (not need_confirm or get_confirm(confirm)):
                print(confirm)
                if which and not shutil.which(which):
                    os.system(cmd)
                else:
                    print('skip, ' + which + ' exists')

            if symlink and (not need_confirm or get_confirm(
                'install ' + name + ' symlink'
            )):
                os.system('source ' + os.path.join(dotfiles_path, symlink))

            if show:
                print(show)


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
