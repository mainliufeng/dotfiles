# Path to your oh-my-zsh installation.
export ZSH=/Users/liufeng/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="cobalt2"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion. Case
# sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git python autojump virtualenv virtualenvwrapper extract sublime zsh-history-substring-search)

# User configuration

export PATH="/usr/local/sbin:/Library/Java/JavaVirtualMachines/jdk1.7.0_55.jdk/Contents/Home/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/git/bin:/usr/local/maven/default/bin"
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

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
export JAVA_HOME=`/usr/libexec/java_home -v 1.7`
export PATH=${JAVA_HOME}/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

## Maven
export M2_HOME=/usr/local/maven/default
export M2_REPO=$HOME/.m2/repository
export PATH=$PATH:$M2_HOME/bin

## Color
alias ls="ls -G"
alias ll="ls -G -l"

## Vim
export VISUAL="/usr/local/bin/vim"

## xxnet
alias proxy_on="export http_proxy=http://127.0.0.1:8087;export https_proxy=http://127.0.0.1:8087"
alias proxy_off="unset http_proxy;unset https_proxy"

## homebrew
export PATH="/usr/local/sbin:$PATH"

## go
export GOPATH=$HOME/go
export GOROOT="/usr/local/Cellar/go/1.6/libexec"
export PATH=$PATH:/usr/local/opt/go/libexec/bin
export PATH=$PATH:$GOPATH/bin

## virtualenv
export WORKON_HOME=~/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh

## docker
alias dockerenv='eval "$(docker-machine env default)"'
alias dm='docker-machine'

## brew
export HOMEBREW_GITHUB_API_TOKEN=97bb71c4dc9166cbaa5eee8599a04d21879ba27c

## mycli
alias mysql='echo "Try mycli!";mysql'

## vim mode
bindkey -v

## show virtualenv name at right
function virtualenv_prompt() {
  if [[ -n ${VIRTUAL_ENV} ]]; then
    echo "%{${fg_bold[white]}%}(env: %{${fg[green]}%}${VIRTUAL_ENV:t}%{${fg_bold[white]}%})%{${reset_color}%}"
  else
    echo -n ""
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
alias m='osascript ~/tools/termtile/maximize.scpt '
alias fs='osascript ~/tools/termtile/fullscreen.scpt '
