## java
JAVA_HOME=$(/usr/libexec/java_home)
export JAVA_HOME
export PATH=${JAVA_HOME}/bin:$PATH
export CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
