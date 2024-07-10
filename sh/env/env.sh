# language environment
export LANG=en_US.UTF-8
export LC_COLLATE="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_ALL=

## fasd
alias v="f -e mvim"

## Color
alias ls="ls --color=auto"
alias ll="ls --color=auto -l"

## pinyin completion
# source /usr/share/pinyin-completion/shell/pinyin-comp.zsh

## color
unset LSCOLORS
export CLICOLOR=1
export CLICOLOR_FORCE=1

## golang
export PATH=$PATH:$HOME/go/bin

## local bin
export PATH=$HOME/.local/bin:$PATH
