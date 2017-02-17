load() {
    case $1 in
    conda)
        if ! hash conda 2>/dev/null; then
            export PATH=~/anaconda3/bin:"$PATH"
            # eval "$(register-python-argcomplete conda)"
        fi
        ;;
    venv)
        if ! hash workon 2>/dev/null; then
            export WORKON_HOME=~/.virtualenvs
            . /usr/local/bin/virtualenvwrapper.sh
        fi
        ;;
    nvm)
        if ! hash nvm 2>/dev/null; then
            export NVM_DIR="$HOME/.nvm"
            . "$(brew --prefix nvm)"/nvm.sh
        fi
        ;;
    minikube)
        eval "$(minikube docker-env)"
        ;;
    *)
        echo "Usage: load conda|venv|nvm|minikube"
        return 0
    esac
}

load conda
