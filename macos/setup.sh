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

if ! confirm "set macos defaults [Y|n]" "Y"; then
    exit 0
fi

case $(uname) in
Darwin)
    printf "set macos defaults\n"
    sh ~/dotfiles/macos/defaults.sh
    ;;
*)
    echo "os not supported"
    exit 1
esac

if ! confirm "set macos file limits [Y|n]" "Y"; then
    exit 0
fi

case $(uname) in
Darwin)
    printf "set macos file limits\n"
    sudo cp -f ~/dotfiles/macos/limit.maxfiles.plist /Library/LaunchDaemons/
    sudo chown root:wheel /Library/LaunchDaemons/limit.maxfiles.plist
    sudo launchctl load -w /Library/LaunchDaemons/limit.maxfiles.plist    ;;
*)
    echo "os not supported"
    exit 1
esac

