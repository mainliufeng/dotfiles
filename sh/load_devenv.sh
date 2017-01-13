function load() {
    case $1 in
    conda)
        if [ ! $commands[conda] ]; then
            export PATH=~/anaconda3/bin:"$PATH"
            eval "$(register-python-argcomplete conda)"
        fi
        ;;
    venv)
        if [ ! $commands[workon] ]; then
            export WORKON_HOME=~/.virtualenvs
            source /usr/local/bin/virtualenvwrapper.sh
        fi
        ;;
    nvm)
        if [ ! $commands[nvm] ]; then
            export NVM_DIR="$HOME/.nvm"
            . "$(brew --prefix nvm)/nvm.sh"
        fi
        ;;
    minikube)
        eval $(minikube docker-env)
        ;;
    *)
        echo "Usage: load conda|venv|nvm|minikube"
        return 0
    esac
}
