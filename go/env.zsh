## go
export GOPATH="$HOME/go"
export PATH="$PATH:$GOPATH/bin"

# macOS (Homebrew) Go
if [[ "$OSTYPE" == darwin* ]]; then
  if [ -d /opt/homebrew/opt/go/libexec ]; then
    export GOROOT="/opt/homebrew/opt/go/libexec"
    export PATH="$PATH:$GOROOT/bin"
  elif [ -d /usr/local/opt/go/libexec ]; then
    export GOROOT="/usr/local/opt/go/libexec"
    export PATH="$PATH:$GOROOT/bin"
  fi
fi
