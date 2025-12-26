if [[ -o interactive ]]; then
  code_agents_config_widget() {
    code-agents-config-console
    zle redisplay
  }
  zle -N code_agents_config_widget
  bindkey -M emacs '^A' code_agents_config_widget
  bindkey -M vicmd '^A' code_agents_config_widget
  bindkey -M viins '^A' code_agents_config_widget
fi
