## python
export PATH="/usr/local/opt/python/libexec/bin:/usr/local/bin:$PATH"

## pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if which pyenv > /dev/null;
    then eval "$(pyenv init -)";
fi

## pipenv
autoload bashcompinit
bashcompinit
source /usr/local/etc/bash_completion.d/pipenv
