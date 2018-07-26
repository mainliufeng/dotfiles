#!/bin/sh 
confirm() {
    while true
    do
        printf "\033[1;33m$1 \033[0m"
    	read -r response
        if [ "$response" = "" ] && [ -z "$2" ]; then 
            response=$2
        fi
    	case $response in
    	    [yY][eE][sS]|[yY])
                return 0
    			;;
    	    [nN][oO]|[nN])
                return 1
    	       	;;
    	    *)
    		echo "Invalid input..."
    		;;
    	esac
    done
}

manual() {
    printf "\033[1;33m$1, and press any key \033[0m"
    read -r
}

if confirm "install mysql [Y|n]" "Y"; then
    case $(uname) in
    Darwin)
        brew install mysql@5.7
        ;;
    *)
        echo "os not supported"
        exit 1
    esac
fi

if confirm "init mysql [Y|n]" "Y"; then
    case $(uname) in
    Darwin)
        brew services start mysql@5.7
        mysql_secure_installation
        ;;
    *)
        echo "os not supported"
        exit 1
    esac
fi
