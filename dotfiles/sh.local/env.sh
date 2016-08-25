## homebrew
export PATH="/usr/local/sbin:$PATH"
export HOMEBREW_GITHUB_API_TOKEN=97bb71c4dc9166cbaa5eee8599a04d21879ba27c

## virtualenv
export WORKON_HOME=~/.virtualenvs
source /usr/local/bin/virtualenvwrapper.sh

## go
export GOPATH=$HOME/go
export GOROOT="/usr/local/Cellar/go/1.6/libexec"
export PATH=$PATH:/usr/local/opt/go/libexec/bin
export PATH=$PATH:$GOPATH/bin

## java
export JAVA_HOME=`/usr/libexec/java_home`
export PATH=${JAVA_HOME}/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar

## maven
export M2_HOME=/usr/local/Cellar/maven/3.3.9
export M2_REPO=$HOME/.m2/repository
export PATH=$PATH:$M2_HOME/bin
export MAVEN_OPTS="-Xmx2g -XX:MaxPermSize=512M -XX:ReservedCodeCacheSize=512m"

## spark
export SPARK_HOME=/usr/local/Cellar/apache-spark/2.0.0
export PYTHONPATH=$SPARK_HOME/python/:$PYTHONPATH

## sbt
export SBT_OPTS="-Dsbt.override.build.repos=true $SBT_OPTS"
