CURRENT_BG='NONE'
SEGMENT_SEPARATOR=''
RSEGMENT_SEPARATOR=', '
HAS_LAST_RPROMPT=''

# Begin a segment
# Takes two arguments, background and foreground. Both can be omitted,
# rendering default background/foreground.
prompt_segment() {
  local bg fg
  [[ -n $1 ]] && bg="%K{$1}" || bg="%k"
  [[ -n $2 ]] && fg="%F{$2}" || fg="%f"
  if [[ $CURRENT_BG != 'NONE' && $1 != $CURRENT_BG ]]; then
    echo -n " %{$bg%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR%{$fg%} "
  else
    echo -n "%{$bg%}%{$fg%} "
  fi
  CURRENT_BG=$1
  [[ -n $3 ]] && echo -n $3
}

rprompt_segment() {
    echo -n "%{%F{green}%}%{%k%}"
    [[ $HAS_LAST_RPROMPT == 'TRUE' ]] && echo -n "$RSEGMENT_SEPARATOR"
    echo -n "$1:"
    echo -n "%{%F{$3}%}%{%k%}"
    [[ -n $2 ]] && echo -n "$2"
    HAS_LAST_RPROMPT="TRUE"
}

# End the prompt, closing any open segments
prompt_end() {
  if [[ -n $CURRENT_BG ]]; then
    echo -n " %{%k%F{$CURRENT_BG}%}$SEGMENT_SEPARATOR"
  else
    echo -n "%{%k%}"
  fi
  echo -n "%{%f%}"
  CURRENT_BG=''
}
