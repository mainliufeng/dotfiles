#!/bin/sh

# golangci-lint
brew install golangci/tap/golangci-lint
brew upgrade golangci/tap/golangci-lint

# 函数圈复杂度计算
go get github.com/fzipp/gocyclo
