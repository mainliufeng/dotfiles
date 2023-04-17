sudo pacman -S go
go env -w GO111MODULE=on

go get github.com/fzipp/gocyclo
go get golang.org/x/tools/gopls@latest
