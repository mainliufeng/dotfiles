## vim
alias vim="nvim"

# vim
export EDITOR="nvim"
export VISUAL="nvim"
export MANPAGER='nvim +Man!'
export MANWIDTH=999

# fix vim-floaterm issue
export GIT_EDITOR="nvim"

bindkey -v

# vi style incremental search
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward  

# bind k and j for VI mode
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
