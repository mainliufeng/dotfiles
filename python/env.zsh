## pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if which pyenv > /dev/null;
    then eval "$(pyenv init -)";
fi
export PYTHON_BUILD_MIRROR_URL="https://pypi.tuna.tsinghua.edu.cn/simple"
