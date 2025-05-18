# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

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
zplug "mattberther/zsh-pyenv"

# theme
source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme
POWERLEVEL10K_LEFT_PROMPT_ELEMENTS=(status dir vcs background_jobs)
POWERLEVEL10K_RIGHT_PROMPT_ELEMENTS=(go_version virtualenv anaconda)
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# allow no match
setopt no_nomatch

# for bin in $DOTFILES_HOME/*/bin; 
# do
#     zplug "$bin", from:local, as:command, use:"(*).(py|sh|zsh)", rename-to:'$1'
# done
# for bin in $DOTFILES_HOME/private/*/bin; 
# do
#     zplug "$bin", from:local, as:command, use:"(*).(py|sh|zsh)", rename-to:'$1'
# done


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

for sh in $DOTFILES_HOME/*/env/*; do [ -f "$sh" ] && source "$sh"; done
for sh in $DOTFILES_HOME/*/env.*sh; do [ -f "$sh" ] && source "$sh"; done
for sh in $DOTFILES_HOME/code/*/env/*; do [ -f "$sh" ] && source "$sh"; done
for sh in $DOTFILES_HOME/code/*/env.*sh; do [ -f "$sh" ] && source "$sh"; done

PRIVATE_DOTFILES_HOME="$HOME/dotfiles-private"
for sh in $PRIVATE_DOTFILES_HOME/*/env.*sh; do source $sh; done

[ -f ~/dotfiles/fzf/.fzf.zsh ] && source ~/dotfiles/fzf/.fzf.zsh


# JINA_CLI_BEGIN

## autocomplete
if [[ ! -o interactive ]]; then
    return
fi

compctl -K _jina jina

_jina() {
  local words completions
  read -cA words

  if [ "${#words}" -eq 2 ]; then
    completions="$(jina commands)"
  else
    completions="$(jina completions ${words[2,-2]})"
  fi

  reply=(${(ps:
:)completions})
}

# session-wise fix
ulimit -n 4096
export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES

# JINA_CLI_END


# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/liufeng/.lmstudio/bin"
# End of LM Studio CLI section

