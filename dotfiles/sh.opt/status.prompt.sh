function status_prompt() {
    if [[ ! -n ${VIRTUAL_ENV} ]] && [[ ! -n ${PROXY_NAME} ]] && [[ ! -n ${SBT_REPOSITORIES} ]] && [[ ! -n ${MAVEN_REPOSITORIES} ]]; then
        echo -n ""
    else
        echo -n "%{${fg_bold[white]}%}("
        local has_first=false

        if [[ -n ${VIRTUAL_ENV} ]]; then
            if $has_first; then 
                echo -n ", "
            fi
            has_first=true
            echo -n "env: %{${fg[green]}%}${VIRTUAL_ENV:t}%{${fg_bold[white]}%}"
        fi

        if [[ -n ${PROXY_NAME} ]]; then
            if $has_first; then 
                echo -n ", "
            fi
            has_first=true
            echo -n "proxy: %{${fg[green]}%}${PROXY_NAME}%{${fg_bold[white]}%}"
        fi

        if [[ -n ${SBT_REPOSITORIES} ]]; then
            if $has_first; then 
                echo -n ", "
            fi
            has_first=true
            echo -n "sbt: %{${fg[green]}%}${SBT_REPOSITORIES}%{${fg_bold[white]}%}"
        fi

        if [[ -n ${MAVEN_REPOSITORIES} ]]; then
            if $has_first; then 
                echo -n ", "
            fi
            has_first=true
            echo -n "mvn: %{${fg[green]}%}${MAVEN_REPOSITORIES}%{${fg_bold[white]}%}"
        fi

        echo ")%{${reset_color}%}"
    fi
}
RPROMPT='$(status_prompt)'
