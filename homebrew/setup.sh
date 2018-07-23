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
Darwin)
    if ! type brew > /dev/null; then
        printf "install homebrew\n"
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        echo "skip homebrew brew command exist"
    fi
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
    brew bundle install --file=~/dotfiles/homebrew/Brewfile-short
    ;;
*)
    echo "os not supported"
    exit 1
esac

if ! confirm "update macos softwares [Y|n]" "Y"; then
    exit 0
fi

case $(uname) in
Darwin)
    sudo softwareupdate -i -a
    ;;
*)
    echo "os not supported"
    exit 1
esac

