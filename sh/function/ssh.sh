#ssh() {
#    /usr/bin/ssh -t "$@" "tmux attach -t liufeng || tmux new -s liufeng; PS1='[\[\e[33;40m\]\u@\h \w]$ '; exec bash"
#}
