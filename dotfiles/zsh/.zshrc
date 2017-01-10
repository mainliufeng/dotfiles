# Check if zplug is installed
if [[ ! -d ~/.zplug ]]; then
  git clone https://github.com/zplug/zplug ~/.zplug
  source ~/.zplug/init.zsh && zplug update --self
fi

# Essential
source ~/.zplug/init.zsh

zplug "robbyrussell/oh-my-zsh", use:"lib/*.zsh"
zplug "plugins/git",     from:oh-my-zsh
zplug "plugins/python",  from:oh-my-zsh
zplug "plugins/fasd",    from:oh-my-zsh
zplug "plugins/extract", from:oh-my-zsh
zplug "plugins/sublime", from:oh-my-zsh
zplug "plugins/docker",  from:oh-my-zsh
zplug "plugins/kubectl", from:oh-my-zsh
zplug "plugins/mvn",     from:oh-my-zsh

# zsh-users
zplug "zsh-users/zsh-syntax-highlighting", defer:2
zplug "zsh-users/zsh-history-substring-search", defer:3

zplug "djui/alias-tips"
zplug "petronny/pinyin-completion"

zplug "wesbos/Cobalt2-iterm", use:"cobalt2.zsh-theme", as:theme

# bind k and j for VI mode
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

## extract
alias -s gz='tar -xzvf'
alias -s bz2='tar -xjvf'

# Install packages that have not been installed yet
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    else
        echo
    fi
fi

zplug load --verbose

for sh in $HOME/dotfiles/dotfiles/sh*/*.*sh;
do
    source $sh
done
