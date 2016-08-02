# load zgen
source "${HOME}/.zgen/zgen.zsh"

# if the init scipt doesn't exist
if ! zgen saved; then
    echo "Creating a zgen save"

    zgen oh-my-zsh

    # oh-my-zsh
    zgen oh-my-zsh plugins/git
    zgen oh-my-zsh plugins/python
    zgen oh-my-zsh plugins/autojump
    zgen oh-my-zsh plugins/virtualenv
    zgen oh-my-zsh plugins/virtualenvwrapper
    zgen oh-my-zsh plugins/extract
    zgen oh-my-zsh plugins/sublime
    zgen oh-my-zsh plugins/docker
    zgen oh-my-zsh plugins/command-not-found
    zgen oh-my-zsh themes/cobalt2

    # zsh-users
    zgen load zsh-users/zsh-completions src
    zgen load zsh-users/zsh-history-substring-search
    zgen load zsh-users/zsh-syntax-highlighting

    # save all to init script
    zgen save
fi

# User configuration

# zsh-history-substring-search
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down

export PATH="/usr/local/sbin:/Library/Java/JavaVirtualMachines/jdk1.7.0_55.jdk/Contents/Home/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/git/bin:/usr/local/maven/default/bin"
# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
export SSH_KEY_PATH="~/.ssh/dsa_id"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

## zsh-completions
plugins+=(zsh-completions)
autoload -U compinit && compinit

## zsh-completions
fpath=(/usr/local/share/zsh-completions $fpath)

## Java
export JAVA_HOME=`/usr/libexec/java_home`
export PATH=${JAVA_HOME}/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

## Maven
export M2_HOME=/usr/local/maven/default
export M2_REPO=$HOME/.m2/repository
export PATH=$PATH:$M2_HOME/bin
export MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=512M -XX:ReservedCodeCacheSize=512m"

## Color
alias ls="ls -G"
alias ll="ls -G -l"

## Vim
export VISUAL="/usr/local/bin/vim"

## proxy
function proxyon() {
    if [[ ! -n "$1" ]]; then
        echo $PROXY_NAME
    else
        if [ "$1" = "xxnet" ]; then
            local port=8087
            export PROXY_NAME="xxnet"
            export http_proxy=http://127.0.0.1:$port
            export https_proxy=http://127.0.0.1:$port
        elif [ "$1" = "ss" ]; then
            local port=8123
            export PROXY_NAME="shadowsocks"
            export http_proxy=http://127.0.0.1:$port
            export https_proxy=http://127.0.0.1:$port
        elif [ "$1" = "null" ]; then
            unset PROXY_NAME
            unset http_proxy
            unset https_proxy
        fi
    fi
}

## sbt
export SBT_OPTS="-Dsbt.override.build.repos=true $SBT_OPTS"
function sbton() {
    if [[ ! -n "$1" ]]; then
        echo $SBT_REPOSITORIES
    else
        if [ "$1" = "work" ]; then
            cp ~/.sbt/repositories.work ~/.sbt/repositories
            export SBT_REPOSITORIES="work"
        elif [ "$1" = "home" ]; then
            cp ~/.sbt/repositories.home ~/.sbt/repositories
            export SBT_REPOSITORIES="home"
        elif [ "$1" = "null" ]; then
            rm -f ~/.sbt/repositories
            unset SBT_REPOSITORIES
        fi
    fi
}

## homebrew
export PATH="/usr/local/sbin:$PATH"
alias service="brew services"

## go
export GOPATH=$HOME/go
export GOROOT="/usr/local/Cellar/go/1.6/libexec"
export PATH=$PATH:/usr/local/opt/go/libexec/bin
export PATH=$PATH:$GOPATH/bin

## virtualenv
export WORKON_HOME=~/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh

## brew
export HOMEBREW_GITHUB_API_TOKEN=97bb71c4dc9166cbaa5eee8599a04d21879ba27c

## mycli
alias mysql='echo "Try mycli!";mysql'

## vim mode
bindkey -v

## show virtualenv name at right
function virtualenv_prompt() {
    if [[ ! -n ${VIRTUAL_ENV} ]] && [[ ! -n ${PROXY_NAME} ]] && [[ ! -n ${SBT_REPOSITORIES} ]]; then
        echo -n ""
    else
        echo -n "%{${fg_bold[white]}%}("
        local has_first=false

        if [[ -n ${VIRTUAL_ENV} ]]; then
            if $has_first; then 
                echo -n ", "
            fi
            has_first=true
            echo -n "env: %{${fg[green]}%}${VIRTUAL_ENV:t}%{${fg_bold[white]}%}"
        fi

        if [[ -n ${PROXY_NAME} ]]; then
            if $has_first; then 
                echo -n ", "
            fi
            has_first=true
            echo -n "proxy: %{${fg[green]}%}${PROXY_NAME}%{${fg_bold[white]}%}"
        fi

        if [[ -n ${SBT_REPOSITORIES} ]]; then
            if $has_first; then 
                echo -n ", "
            fi
            has_first=true
            echo -n "sbt: %{${fg[green]}%}${SBT_REPOSITORIES}%{${fg_bold[white]}%}"
        fi

        echo ")%{${reset_color}%}"
    fi
}
RPROMPT='$(virtualenv_prompt)'


# Added by termtile (https://github.com/apaszke/termtile)
alias fl='osascript ~/tools/termtile/tile.scpt left'
alias fr='osascript ~/tools/termtile/tile.scpt right'
alias up='osascript ~/tools/termtile/tile.scpt up'
alias down='osascript ~/tools/termtile/tile.scpt down'
alias big='osascript ~/tools/termtile/resize.scpt '
alias cen='osascript ~/tools/termtile/center.scpt '
alias max='osascript ~/tools/termtile/maximize.scpt '
alias fs='osascript ~/tools/termtile/fullscreen.scpt '

# max
alias m='max;clear;'

## xxnet
alias xxnet='/usr/local/xxnet/current/start'

## spark
export SPARK_HOME=/usr/local/spark/current
export PYTHONPATH=$SPARK_HOME/python/:$PYTHONPATH
alias spark_debug_on='export SPARK_JAVA_OPTS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5555'
alias spark_debug_off='unset SPARK_JAVA_OPTS'

## extract
alias -s gz='tar -xzvf'
alias -s bz2='tar -xjvf'

## pget
alias wget='echo "Try pget!";wget'

## rm
alias rm='echo "Use trash!!!";rm'
