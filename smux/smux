#! /usr/bin/env bash
target=$(tmux list-windows -a -F '#{session_name} #{window_name}' | fzf-tmux +m --reverse --ansi)
res=$?
[ "$res" -eq "130" ] && exit 0
[ "$res" -eq "0" ] || exit $res

target_session=$(echo "$target" | cut -d' ' -f1)
target_window=$(echo "$target" | cut -d' ' -f2)
target_window=$(echo "$target_window" | cut -d'.' -f1)

tmux switch-client -t "$target_session" \; select-window -t "$target_window"
