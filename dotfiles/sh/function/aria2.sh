function aria2() {
    if [[ ! -n "$1" ]]; then
        echo "Usage aria2 start|stop|status"
        return 1
    fi

    case $1 in
    start)
        bash -c "nohup aria2c --conf-path=\"/Users/liufeng/.aria2/aria2.conf\" > /Users/liufeng/.aria2/aria2.log 2>&1 &"
        ;;
    stop)
        pkill aria2
        ;;
    status)
        ps -ef | grep aria2
        ;;
    *)
        echo "invalid subcommand"
        return 1
    esac
}
