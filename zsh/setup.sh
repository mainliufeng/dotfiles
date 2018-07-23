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

if ! confirm "install zsh [Y|n]" "Y"; then
    exit 0
fi

case $(uname) in
Linux)
    printf "install zsh\n"
    sudo apt-get install zsh
    chsh -s /bin/zsh user
    ;;
Darwin)
    printf "install zsh\n"
    brew install zsh
    sudo -s 'echo /usr/local/bin/zsh >> /etc/shells' && chsh -s /usr/local/bin/zsh
    ;;
*)
    echo "os not supported"
    exit 1
esac

if ! type zplug > /dev/null; then
    printf "zplug already installed\n"
else
    printf "install zplug\n"
    curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh| zsh
fi

printf "use zsh\n"
chsh -s /bin/zsh

printf "install config files\n"
sh ~/dotfiles/zsh/zsh.symlink

manual "now check zsh manually"
