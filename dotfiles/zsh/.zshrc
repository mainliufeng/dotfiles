source "${HOME}/.zgen/zgen.zsh"

# if the init scipt doesn't exist
if ! zgen saved; then

    # specify plugins here
    zgen oh-my-zsh
    zgen oh-my-zsh themes/cobalt2
    zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/python
    zgen oh-my-zsh plugins/fasd
    zgen oh-my-zsh plugins/extract
    zgen oh-my-zsh plugins/sublime
    zgen oh-my-zsh plugins/docker
    zgen oh-my-zsh plugins/kubectl
    zgen oh-my-zsh plugins/mvn
    
    zgen load zsh-users/zsh-syntax-highlighting
    zgen load zsh-users/zsh-history-substring-search
    
    zgen load djui/alias-tips

    zgen load /usr/local/opt/pinyin-completion/libexec/shell/pinyin-comp.zsh
    
    # bind k and j for VI mode
    bindkey -M vicmd 'k' history-substring-search-up
    bindkey -M vicmd 'j' history-substring-search-down
    
    # generate the init script from plugins above
    zgen save

fi

## extract
alias -s gz='tar -xzvf'
alias -s bz2='tar -xjvf'

for config_sh in ~/dotfiles/dotfiles/sh*/*.*sh; do
    source $config_sh
done
