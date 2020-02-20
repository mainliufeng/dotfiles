# language environment
export LANG=en_US.UTF-8
export LC_COLLATE="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_ALL=

## java
JAVA_HOME=/usr/lib/jvm/default
export JAVA_HOME
export PATH=${JAVA_HOME}/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

## maven
export M2_REPO=$HOME/.m2/repository
export PATH=$PATH:$M2_HOME/bin
export MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=512M -XX:ReservedCodeCacheSize=512m"

## pinyin completion
source /usr/share/pinyin-completion/shell/pinyin-comp.zsh

## trash
alias rm='echo "rm is disabled, use trash or /bin/rm instead."'

## color
unset LSCOLORS
export CLICOLOR=1
export CLICOLOR_FORCE=1

## docker
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

## golang
export PATH=$PATH:$HOME/go/bin
