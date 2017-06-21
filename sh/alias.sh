## Color
alias ls="ls -G"
alias ll="ls -G -l"

## Git
alias gglg="git lg"
alias gd="git diff --color | diff-so-fancy"

## emacs
alias e="emacs"
alias ec="emacsclient"
alias enw="emacsclient -nw"
alias et="emacsclient -t"

## vim
alias vim="nvim"

es() {
    case $1 in
    start)
        brew services start emacs
        ;;
    stop)
        brew services stop emacs
        ;;
    restart)
        brew services restart emacs
        ;;
    *)
        echo "Usage es start|stop|restart"
        return 1
    esac
}
