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

if ! confirm "install vim [Y|n]" "Y"; then
    exit 0
fi

case $(uname) in
Linux)
    printf "install vim\n"
    sudo apt-get install vim
    ;;
Darwin)
    printf "install macvim\n"
    brew install macvim
    ;;
*)
    echo "os not supported"
    exit 1
esac

printf "install vim-plug\n"
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

printf "install config files\n"
sh ~/dotfiles/vim/vim.symlink

manual "now run vim command 'PlugInstall' manually"
