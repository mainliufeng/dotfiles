function proxyon() {
    if [[ ! -n "$1" ]]; then
        unset PROXY_NAME
        unset http_proxy
        unset https_proxy
        return 0
    fi

    case $1 in
    xxnet)
        port=8087
        ;;
    surge)
        port=6152
        ;;
    *)
        echo "invalid proxy name"
        return 1
    esac

    export PROXY_NAME="$1"
    export http_proxy=http://127.0.0.1:$port
    export https_proxy=http://127.0.0.1:$port
}
