# Check if zplug is installed
DOTFILES_HOME="$HOME/dotfiles"
ZPLUG_HOME="$HOME/.zplug"
if [[ ! -d $ZPLUG_HOME ]]; then
  git clone https://github.com/zplug/zplug $ZPLUG_HOME
  source $ZPLUG_HOME/init.zsh && zplug update --self
fi

# Essential
source $ZPLUG_HOME/init.zsh

# oh-my-zsh
zplug "robbyrussell/oh-my-zsh", use:"lib/history.zsh"
zplug "robbyrussell/oh-my-zsh", use:"lib/theme-and-appearance.zsh"
zplug "plugins/git",          from:oh-my-zsh
zplug "plugins/python",       from:oh-my-zsh
zplug "plugins/fasd",         from:oh-my-zsh
zplug "plugins/extract",      from:oh-my-zsh
#zplug "plugins/sublime",      from:oh-my-zsh
zplug "plugins/docker",       from:oh-my-zsh
#zplug "plugins/kubectl",      from:oh-my-zsh
zplug "plugins/mvn",          from:oh-my-zsh
zplug "plugins/taskwarrior",  from:oh-my-zsh
zplug "plugins/supervisor",  from:oh-my-zsh
zplug "plugins/tmux",  from:oh-my-zsh

# zsh-users
#zplug "zsh-users/zsh-syntax-highlighting", defer:2
#zplug "zsh-users/zsh-history-substring-search", defer:3
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-history-substring-search"

zplug "djui/alias-tips"
zplug "/usr/local/opt/pinyin-completion/libexec", from:local, use:"shell/pinyin-comp.zsh"
zplug "lukechilds/gifgen", as:command, use:"gifgen"
zplug "tmuxinator/tmuxinator", use:"completion/tmuxinator.zsh"

# local plugins
zplug "$DOTFILES_HOME/sh/function", from:local, use:"*.sh"

# theme
zplug "wesbos/Cobalt2-iterm", use:"cobalt2.zsh-theme", as:theme
zplug "$DOTFILES_HOME/zsh/plugins/rprompt", from:local

# resource (download only)
zplug "altercation/solarized", ignore:"*"
zplug "abertsch/Menlo-for-Powerline", hook-build:"cp -f $ZPLUG_HOME/repos/abertsch/Menlo-for-Powerline/*.ttf ~/.fonts/ && fc-cache -vf ~/.fonts", ignore:"*"

# Install packages that have not been installed yet
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    else
        echo
    fi
fi

zplug load

for sh in $DOTFILES_HOME/sh/*.sh; do source $sh; done

# private scripts
for sh in $DOTFILES_HOME/sh/private/*.sh; do source $sh; done

# always have a tmux session on
if ! { [ "$TERM" = "screen-256color" ] && [ -n "$TMUX" ]; } then
    tmux attach -t base || tmux new -s base; tmux detach
fi
