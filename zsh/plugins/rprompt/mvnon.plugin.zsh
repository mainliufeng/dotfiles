function mvnon() {
    if [[ ! -n "$1" ]]; then
        unalias mvn 2>/dev/null
        unset MAVEN_REPOSITORIES
        return 0
    fi

    SETTINGS_FILE="$HOME/.m2/settings.xml.$1"
    if [ ! -f $SETTINGS_FILE ]; then
        echo "File not found: $SETTINGS_FILE"
        return 1
    fi

    alias mvn="mvn --settings=$SETTINGS_FILE"
    export MAVEN_REPOSITORIES="$1"
}
