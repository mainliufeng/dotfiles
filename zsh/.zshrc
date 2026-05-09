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
  git clone https://github.com/zplug/zplug "$ZPLUG_HOME"
  source "$ZPLUG_HOME/init.zsh" && zplug update --self
fi

# completion
fpath=("$DOTFILES_HOME/codex/agents_md" $fpath)
if [[ -z "${_comps:-}" ]]; then
  autoload -Uz compinit
  compinit
fi

# Essential
source "$ZPLUG_HOME/init.zsh"

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

# theme
for p10k_theme in \
  /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme \
  /usr/local/share/powerlevel10k/powerlevel10k.zsh-theme \
  /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme; do
  if [[ -r "$p10k_theme" ]]; then
    source "$p10k_theme"
    break
  fi
done
POWERLEVEL10K_LEFT_PROMPT_ELEMENTS=(status dir vcs background_jobs)
POWERLEVEL10K_RIGHT_PROMPT_ELEMENTS=(go_version virtualenv anaconda)
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

for sh in "$DOTFILES_HOME"/*/env/*; do [ -f "$sh" ] && source "$sh"; done
for sh in "$DOTFILES_HOME"/*/env.*sh; do [ -f "$sh" ] && source "$sh"; done
for sh in "$DOTFILES_HOME"/code/*/env/*; do [ -f "$sh" ] && source "$sh"; done
for sh in "$DOTFILES_HOME"/code/*/env.*sh; do [ -f "$sh" ] && source "$sh"; done

PRIVATE_DOTFILES_HOME="$HOME/dotfiles-private"
for sh in "$PRIVATE_DOTFILES_HOME"/*/env.*sh; do [ -f "$sh" ] && source "$sh"; done

[ -f ~/dotfiles/fzf/.fzf.zsh ] && source ~/dotfiles/fzf/.fzf.zsh
[ -f "$DOTFILES_HOME/code_agents/.code_agents.zsh" ] && source "$DOTFILES_HOME/code_agents/.code_agents.zsh"

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi


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
export PATH="$PATH:$HOME/.lmstudio/bin"
# End of LM Studio CLI section


# Android SDK
if [[ "$(uname -s)" == "Linux" && -d /opt/android-sdk ]]; then
  export ANDROID_HOME=/opt/android-sdk
  export PATH="$PATH:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin"
fi

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# pnpm
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# OpenClaw Completion
[ -f "$HOME/.openclaw/completions/openclaw.zsh" ] && source "$HOME/.openclaw/completions/openclaw.zsh"
