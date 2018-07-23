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

if confirm "install tmux [Y|n]" "Y"; then
    case $(uname) in
    Linux)
        sudo apt-get install tmux
        ;;
    Darwin)
        brew install tmux
        ;;
    *)
        echo "os not supported"
        exit 1
    esac
fi


if confirm "install tmuxp [Y|n]" "Y"; then
    pip install -e ~/dotfiles/tmuxp
fi

printf "install config files\n"
sh ~/dotfiles/tmux/tmux.symlink

manual "now check tmux and tmuxp manually"
