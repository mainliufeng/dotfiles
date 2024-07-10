insert_output_to_next_prompt() {
    local output
    output=$(eval mobius_shell '"$BUFFER"')
    BUFFER="$output"
    zle reset-prompt
}

zle -N insert_output_to_next_prompt
bindkey '^g' insert_output_to_next_prompt
