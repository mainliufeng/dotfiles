# Check if zplug is installed
DOTFILES_HOME="$HOME/dotfiles"
ZPLUG_HOME="$HOME/.zplug"
if [[ ! -d $ZPLUG_HOME ]]; then
  git clone https://github.com/zplug/zplug $ZPLUG_HOME
  source $ZPLUG_HOME/init.zsh && zplug update --self
fi

# Essential
source $ZPLUG_HOME/init.zsh

# History size
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000000
SAVEHIST=10000000

# oh-my-zsh
zplug "robbyrussell/oh-my-zsh", use:"lib/history.zsh"
zplug "robbyrussell/oh-my-zsh", use:"lib/theme-and-appearance.zsh"
zplug "plugins/git",          from:oh-my-zsh
zplug "plugins/python",       from:oh-my-zsh
zplug "plugins/fasd",         from:oh-my-zsh
zplug "plugins/extract",      from:oh-my-zsh

# zsh-users
#zplug "zsh-users/zsh-syntax-highlighting", defer:2
#zplug "zsh-users/zsh-history-substring-search", defer:3
zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-history-substring-search" 
zplug "djui/alias-tips"
zplug "lukechilds/gifgen", as:command, use:"gifgen"

# theme
zplug "$DOTFILES_HOME/theme", from:local, use:"cobalt2.zsh-theme", as:theme

# resource (download only)
zplug "altercation/solarized", ignore:"*"
zplug "abertsch/Menlo-for-Powerline", hook-build:"mkdir -p ~/.fonts && cp -f $ZPLUG_HOME/repos/abertsch/Menlo-for-Powerline/*.ttf ~/.fonts/ && fc-cache -vf ~/.fonts", ignore:"*"

# allow no match
setopt no_nomatch

for bin in $DOTFILES_HOME/*/bin; 
do
    zplug "$bin", from:local, as:command, use:"(*).(py|sh|zsh)", rename-to:'$1'
done
for bin in $DOTFILES_HOME/private/*/bin; 
do
    zplug "$bin", from:local, as:command, use:"(*).(py|sh|zsh)", rename-to:'$1'
done


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

for sh in $DOTFILES_HOME/*/env/*; do source $sh; done
for sh in $DOTFILES_HOME/*/env.*sh; do source $sh; done
# for sh in $DOTFILES_HOME/private/*/env/*; do source $sh; done
for sh in $DOTFILES_HOME/private/*/env.*sh; do source $sh; done
