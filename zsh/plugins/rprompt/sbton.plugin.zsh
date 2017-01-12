function sbton() {
    if [[ ! -n "$1" ]]; then
        export SBT_OPTS="$_SBT_OPTS_STATIC"
        unset SBT_REPOSITORIES
        return 0
    fi

    case $1 in
    work)
        sbt_repo_file="~/.sbt/repositories.work"
        ;;
    home)
        sbt_repo_file="~/.sbt/repositories.home"
        ;;
    *)
        echo "invalid sbt repository name"
        return 1
        ;;
    esac

    export SBT_OPTS="$_SBT_OPTS_STATIC -Dsbt.repository.config=$sbt_repo_file"
    export SBT_REPOSITORIES="$1"
}
