let g:ale_go_golangci_lint_package = 1
let g:ale_open_list = 0
let g:ale_set_loclist = 0
let g:ale_set_quickfix = 1

let g:ale_linters = {'go': ['gofmt', 'golint', 'go vet', 'golangci-lint']}
let g:ale_golangci_lint_options = '--enable gocyclo'
