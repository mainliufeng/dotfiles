## homebrew
export PATH="/usr/local/sbin:$PATH"
export HOMEBREW_GITHUB_API_TOKEN=97bb71c4dc9166cbaa5eee8599a04d21879ba27c

## mysql
export PATH="/usr/local/opt/mysql@5.7/bin:$PATH"

## ssl
export LDFLAGS="-L/usr/local/opt/openssl/lib"
export CPPFLAGS="-I/usr/local/opt/openssl/include"
export PKG_CONFIG_PATH="/usr/local/opt/openssl/lib/pkgconfig"

## go
export GOPATH=$HOME/go
export GOROOT="/usr/local/opt/go/libexec"
export PATH=$PATH:/usr/local/opt/go/libexec/bin
export PATH=$PATH:$GOPATH/bin

## java
JAVA_HOME=$(/usr/libexec/java_home)
export JAVA_HOME
export PATH=${JAVA_HOME}/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

## maven
export M2_REPO=$HOME/.m2/repository
export PATH=$PATH:$M2_HOME/bin
export MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=512M -XX:ReservedCodeCacheSize=512m"

## sbt
export SBT_OPTS="-Dsbt.override.build.repos=true $SBT_OPTS"
export _SBT_OPTS_STATIC=$SBT_OPTS

## spark
export SPARK_HOME=/usr/local/opt/apache-spark/libexec
#export PYTHONPATH=$SPARK_HOME/python/:$PYTHONPATH
alias spark_debug_on='export SPARK_JAVA_OPTS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5555'
alias spark_debug_off='unset SPARK_JAVA_OPTS'

## python
export PATH="/usr/local/opt/python/libexec/bin:/usr/local/bin:$PATH"

## pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if which pyenv > /dev/null;
    then eval "$(pyenv init -)";
fi

## rabbitmq
autoload bashcompinit
bashcompinit
source /usr/local/etc/bash_completion.d/rabbitmqadmin.bash

## pipenv
autoload bashcompinit
bashcompinit
source /usr/local/etc/bash_completion.d/pipenv
