# docker
docker_clean_images() {
    docker rmi "$(docker images --filter \"dangling=true\" -q --no-trunc)"
}

docker_rmi_like() {
    if [ ! -n "$1" ]; then
        return 1
    fi
    docker rmi "$(docker images | grep "$1" | awk '{print $3}')"
}

docker_rmi_like_force() {
    if [ ! -n "$1" ]; then
        return 1
    fi
    docker rmi -f "$(docker images | grep "$1" | awk '{print $3}')"
}
