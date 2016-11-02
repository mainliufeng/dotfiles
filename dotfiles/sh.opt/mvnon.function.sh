function mvnon() {
    if [[ ! -n "$1" ]]; then
        unalias mvn 2>/dev/null
        unset MAVEN_REPOSITORIES
        return 0
    fi

    case $1 in
    work)
        alias mvn='mvn --settings=$HOME/.m2/settings.xml.work'
        export MAVEN_REPOSITORIES="work"
        ;;
    *)
        echo "invalid maven repository name"
        return 1
        ;;
    esac
}
