## spark
export SPARK_HOME=/usr/local/opt/apache-spark/libexec
#export PYTHONPATH=$SPARK_HOME/python/:$PYTHONPATH

alias spark_debug_on='export SPARK_JAVA_OPTS=-agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5555'
alias spark_debug_off='unset SPARK_JAVA_OPTS'
