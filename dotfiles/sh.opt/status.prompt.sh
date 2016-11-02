function status_prompt() {

    all_empty=true
    for i in VIRTUAL_ENV PROXY_NAME SBT_REPOSITORIES MAVEN_REPOSITORIES
    do
        if [[ -n ${(P)i} ]]; then
            all_empty=false
        fi
    done

    if $all_empty; then
        echo -n ""
        return 0
    fi

    echo -n "%{${fg_bold[white]}%}("
    is_first=true

    for i in env,VIRTUAL_ENV proxy,PROXY_NAME sbt,SBT_REPOSITORIES mvn,MAVEN_REPOSITORIES ;
    do 
        array=("${(@s/,/)i}")
        key=$array[1]
        var_name=$array[2]

        if [[ -n ${(P)var_name} ]]; then
            if $is_first; then
                is_first=false
            else
                echo -n ", "
            fi
            
            echo -n "$key: %{${fg[green]}%}${(P)var_name:t}%{${fg_bold[white]}%}"
        fi
    done

    echo ")%{${reset_color}%}"
}
