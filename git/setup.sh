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

if ! confirm "install homebrew [Y|n]" "Y"; then
    exit 0
fi

case $(uname) in
Linux)
    printf "install git"
    sudo apt-get install git
    ;;
Darwin)
    printf "install git"
    brew install git
    ;;
*)
    echo "os not supported"
    exit 1
esac

if ! confirm "install brew apps [Y|n]" "Y"; then
    exit 0
fi

case $(uname) in
Darwin)
    printf "install brew apps\n"
    brew bundle --file ~/dotfiles/brewfiles/Brewfile.base
    brew bundle --file ~/dotfiles/brewfiles/Brewfile.home
    brew bundle --file ~/dotfiles/brewfiles/Brewfile.develop
    brew bundle --file ~/dotfiles/brewfiles/Brewfile.design
    # sudo softwareupdate -i -a
    ;;
*)
    echo "os not supported"
    exit 1
esac

