## proxy
function proxyon() {
    if [[ ! -n "$1" ]]; then
        echo $PROXY_NAME
    else
        if [ "$1" = "xxnet" ]; then
            local port=8087
            export PROXY_NAME="xxnet"
            export http_proxy=http://127.0.0.1:$port
            export https_proxy=http://127.0.0.1:$port
        elif [ "$1" = "ss" ]; then
            local port=8123
            export PROXY_NAME="shadowsocks"
            export http_proxy=http://127.0.0.1:$port
            export https_proxy=http://127.0.0.1:$port
        elif [ "$1" = "null" ]; then
            unset PROXY_NAME
            unset http_proxy
            unset https_proxy
        fi
    fi
}

## sbt
function sbton() {
    if [[ ! -n "$1" ]]; then
        echo $SBT_REPOSITORIES
    else
        if [ "$1" = "work" ]; then
            export SBT_OPTS="-Dsbt.override.build.repos=true -Dsbt.repository.config=~/.sbt/repositories.work"
            export SBT_REPOSITORIES="work"
        elif [ "$1" = "home" ]; then
            export SBT_OPTS="-Dsbt.override.build.repos=true -Dsbt.repository.config=~/.sbt/repositories.home"
            export SBT_REPOSITORIES="home"
        elif [ "$1" = "null" ]; then
            export SBT_OPTS="-Dsbt.override.build.repos=true -Dsbt.repository.config=~/.sbt/repositories"
            unset SBT_REPOSITORIES
        fi
    fi
}
