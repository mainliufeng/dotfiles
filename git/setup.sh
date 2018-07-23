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

if ! confirm "install git and hub [Y|n]" "Y"; then
    exit 0
fi

case $(uname) in
Linux)
    printf "install git"
    sudo apt-get install git
    ;;
Darwin)
    printf "install git and hub"
    brew install git
    brew install hub
    ;;
*)
    echo "os not supported"
    exit 1
esac
