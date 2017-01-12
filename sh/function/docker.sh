function docker-clean-images() {
    docker rmi $(docker images --filter \"dangling=true\" -q --no-trunc)
}

function docker-rmi-like() {
    if [[ ! -n "$1" ]]; then
        return 1
    fi
    docker rmi $(docker images | grep "$1" | awk '{print $3}')
}

function docker-rmi-like-force() {
    if [[ ! -n "$1" ]]; then
        return 1
    fi
    docker rmi -f $(docker images | grep "$1" | awk '{print $3}')
}
