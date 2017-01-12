# Check if zplug is installed
if [[ ! -d ~/.zplug ]]; then
  git clone https://github.com/zplug/zplug ~/.zplug
  source ~/.zplug/init.zsh && zplug update --self
fi

# Essential
source ~/.zplug/init.zsh

zplug "robbyrussell/oh-my-zsh", use:"lib/history.zsh"
zplug "robbyrussell/oh-my-zsh", use:"lib/theme-and-appearance.zsh"
zplug "plugins/git",     from:oh-my-zsh
zplug "plugins/python",  from:oh-my-zsh
zplug "plugins/fasd",    from:oh-my-zsh
zplug "plugins/extract", from:oh-my-zsh
#zplug "plugins/sublime", from:oh-my-zsh
zplug "plugins/docker",  from:oh-my-zsh
#zplug "plugins/kubectl", from:oh-my-zsh
zplug "plugins/mvn",     from:oh-my-zsh

# zsh-users
#zplug "zsh-users/zsh-syntax-highlighting", defer:2
#zplug "zsh-users/zsh-history-substring-search", defer:3
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-history-substring-search"

zplug "djui/alias-tips"
zplug "/usr/local/opt/pinyin-completion/libexec", from:local, use:"shell/pinyin-comp.zsh"

zplug "~/dotfiles/zsh/plugins/rprompt", from:local
zplug "~/dotfiles/sh/function", from:local, use:"*.sh"

zplug "wesbos/Cobalt2-iterm", use:"cobalt2.zsh-theme", as:theme

# resource download only
zplug "altercation/solarized", ignore:"*"
zplug "abertsch/Menlo-for-Powerline", hook-build:"cp -f ~/.zplug/repos/abertsch/Menlo-for-Powerline/*.ttf ~/.fonts/ && fc-cache -vf ~/.fonts", ignore:"*"

# bind k and j for VI mode
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

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

for sh in $HOME/dotfiles/sh/*.sh; do source $sh; done
