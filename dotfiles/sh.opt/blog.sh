export BLOG_HOME=$HOME/Code/github/mainliufeng.github.io
export BLOG_LOG_FILE=$HOME/.blog.log
export BLOG_PID_FILE=$HOME/.blog.pid

function blog() {

case $1 in
start)
    if [ -f "$BLOG_PID_FILE" ]
    then
        if kill -0 `cat "$BLOG_PID_FILE"` > /dev/null 2>&1; then
            echo 'blog already running'
            return 0
        fi
    fi

    nohup jekyll server -s $BLOG_HOME -d $BLOG_HOME/_site > $BLOG_LOG_FILE &
    if [ $? -eq 0 ]
    then
        echo -n $! > "$BLOG_PID_FILE"
        if [ $? -eq 0 ];
        then
            sleep 1
            echo STARTED
        else
            echo FAILED TO WRITE PID
            return 1
        fi
    else
        echo SERVER DID NOT START
        return 1
    fi
    ;;
stop)
    if [ ! -f "$BLOG_PID_FILE" ]
    then
        echo "no blog to stop (could not find file $BLOG_PID_FILE)"
    else
        kill -9 $(cat "$BLOG_PID_FILE")
        rm "$BLOG_PID_FILE"
        echo STOPPED
    fi
    return 0
    ;;
status)
    if [ -f "$BLOG_PID_FILE" ]
    then
        if kill -0 `cat "$BLOG_PID_FILE"` > /dev/null 2>&1; then
            echo 'status: running'
            return 0
        fi
    fi
    echo 'status: stop'
    return 0
    ;;
open)
    open http://127.0.0.1:4000/
    ;;
*)
    echo "Usage: $0 {status|start|stop|open}" >&2
esac
}
