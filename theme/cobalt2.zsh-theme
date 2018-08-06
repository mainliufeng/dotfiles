DOTFILES_HOME="$HOME/dotfiles" source "$DOTFILES_HOME/common/prompt.sh"

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Context: user@hostname (who am I and where am I)
prompt_context() {
  local user=`whoami`

  if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)✝"
  fi
}

# Git: branch/detached head, dirty status
prompt_git() {
  local ref dirty
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    ZSH_THEME_GIT_PROMPT_DIRTY='±'
    dirty=$(parse_git_dirty)
    ref=$(git symbolic-ref HEAD 2> /dev/null) || ref="➦ $(git show-ref --head -s --abbrev |head -n1 2> /dev/null)"
    if [[ -n $dirty ]]; then
      prompt_segment yellow black
    else
      prompt_segment green black
    fi
    echo -n "${ref/refs\/heads\// }$dirty"
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment blue black '%3~'
  # prompt_segment blue black "…${PWD: -30}"
}

# Status:
# - was there an error
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $RETVAL -ne 0 ]] && symbols+="%{%F{red}%}✘"
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}⚡"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}⚙"

  [[ -n "$symbols" ]] && prompt_segment black default "$symbols"
}

prompt_pyenv() {
    local env_pyenv=$(pyenv version-name 2>/dev/null)
    [[ -n "$env_pyenv" ]] && rprompt_segment "py" "$env_pyenv" yellow 
}

prompt_pipenv() {
    local env_pipenv=$(pipenv --venv 2>/dev/null | grep -oE "[^/]+$")
    [[ -n "$env_pipenv" ]] && rprompt_segment "env" "$env_pipenv" gray
}

## Main prompt
build_prompt() {
  RETVAL=$?
  prompt_status
  prompt_context
  prompt_dir
  prompt_git
  prompt_end
}

build_rprompt() {
  prompt_pyenv
  prompt_pipenv
}

PROMPT='%{%f%b%k%}$(build_prompt) '
#RPROMPT='%{%f%b%k%}$(build_rprompt)'
