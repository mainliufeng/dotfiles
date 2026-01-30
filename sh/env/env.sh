# language environment
export LANG=en_US.UTF-8
export LC_COLLATE="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export LC_MESSAGES="en_US.UTF-8"
export LC_MONETARY="en_US.UTF-8"
export LC_NUMERIC="en_US.UTF-8"
export LC_TIME="en_US.UTF-8"
export LC_ALL=

## color
unset LSCOLORS
export CLICOLOR=1
export CLICOLOR_FORCE=1

# ls colors (GNU ls)
if ls --color=auto >/dev/null 2>&1; then
  alias ls="ls --color=auto"
  alias ll="ls --color=auto -l"
fi

## docker helpers (optional)
docker_clean_images() {
  docker rmi "$(docker images --filter 'dangling=true' -q --no-trunc)" 2>/dev/null
}

docker_rmi_like() {
  [ -n "$1" ] || return 1
  docker rmi "$(docker images | grep "$1" | awk '{print $3}')"
}

docker_rmi_like_force() {
  [ -n "$1" ] || return 1
  docker rmi -f "$(docker images | grep "$1" | awk '{print $3}')"
}

## golang
export PATH="$PATH:$HOME/go/bin"
export GO111MODULE=on
export GOPROXY=https://goproxy.cn
