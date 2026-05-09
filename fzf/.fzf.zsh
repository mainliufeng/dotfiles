# Auto-completion
# ---------------
for fzf_completion in \
  /opt/homebrew/opt/fzf/shell/completion.zsh \
  /usr/local/opt/fzf/shell/completion.zsh \
  /usr/share/fzf/completion.zsh; do
  [[ $- == *i* && -r "$fzf_completion" ]] && source "$fzf_completion" 2> /dev/null
done

# Key bindings
# ------------
for fzf_keybindings in \
  /opt/homebrew/opt/fzf/shell/key-bindings.zsh \
  /usr/local/opt/fzf/shell/key-bindings.zsh \
  /usr/share/fzf/key-bindings.zsh; do
  [[ -r "$fzf_keybindings" ]] && source "$fzf_keybindings"
done
