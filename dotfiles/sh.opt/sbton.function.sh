function sbton() {
    if [[ ! -n "$1" ]]; then
        echo $SBT_REPOSITORIES
    else
        if [ "$1" = "work" ]; then
            export SBT_OPTS="$_SBT_OPTS_STATIC -Dsbt.repository.config=~/.sbt/repositories.work"
            export SBT_REPOSITORIES="work"
        elif [ "$1" = "home" ]; then
            export SBT_OPTS="$_SBT_OPTS_STATIC -Dsbt.repository.config=~/.sbt/repositories.home"
            export SBT_REPOSITORIES="home"
        elif [ "$1" = "null" ]; then
            export SBT_OPTS="$_SBT_OPTS_STATIC"
            unset SBT_REPOSITORIES
        fi
    fi
}
