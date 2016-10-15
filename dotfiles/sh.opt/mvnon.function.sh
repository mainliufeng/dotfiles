function mvnon() {
    if [[ ! -n "$1" ]]; then
        echo $MAVEN_REPOSITORIES
    else
        if [ "$1" = "work" ]; then
            alias mvn='mvn --settings=$HOME/.m2/settings.xml.work'
            export MAVEN_REPOSITORIES="work"
        elif [ "$1" = "null" ]; then
            unalias mvn
            unset MAVEN_REPOSITORIES
        fi
    fi
}
