## pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if which pyenv > /dev/null;
    then eval "$(pyenv init -)";
fi
export PYTHON_BUILD_MIRROR_URL="https://pypi.tuna.tsinghua.edu.cn/simple"

### virtualenvwrapper
#export WORKON_HOME=$HOME/.virtualenvs
#source /usr/bin/virtualenvwrapper.sh
#
### conda
#source /opt/anaconda/etc/profile.d/conda.sh
