envvar_prompt() {
    display_name=$1
    env_var=$2
    env_var_value=${(P)env_var}

    if [[ -n $env_var_value ]]; then
        echo -n "$display_name: %{${fg[green]}%}$env_var_value%{${fg_bold[white]}%}, "
    fi
}

prompt_content() {
    envvar_prompt env VIRTUAL_ENV
    envvar_prompt proxy PROXY_NAME
    envvar_prompt sbt SBT_REPOSITORIES
    envvar_prompt mvn MAVEN_REPOSITORIES
    envvar_prompt conda CONDA_DEFAULT_ENV
}

status_prompt() {
    content="$(prompt_content)"
    if [[ -n $content ]]; then
        echo -n "%{${fg_bold[white]}%}("
        echo -n ${content:0:-2}
        echo ")%{${reset_color}%}"
    fi
}

RPROMPT='$(status_prompt)'
