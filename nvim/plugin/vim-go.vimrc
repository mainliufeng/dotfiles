let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

" change gofmt to goimports
let g:go_fmt_command = "goimports"

" syntax highlighting
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_operators = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_build_constraints = 1

let g:go_code_completion_enabled = 0

" lint
let g:go_list_type = "quickfix"
"let g:go_list_height = 0
let g:go_list_autoclose = 1
let g:go_jump_to_error = 0
"let g:go_metalinter_enabeld = ['deadcode', 'errcheck', 'gosimple', 'govet', 'staticcheck', 'typecheck', 'unused', 'varcheck']
let g:go_metalinter_enabeld = ['vet', 'golint', 'errcheck', 'gocyclo']
let g:go_metalinter_command = "golangci-lint"
let g:go_metalinter_deadline = "15s"
let g:go_metalinter_autosave = 0
let g:go_metalinter_autosave_enabled = ['vet', 'golint', 'gocyclo']

"
let g:go_guru_scope = []

" go code coverage
" run :GoCoverageToggle to show/hide go file coverage

" disable mapping
let g:go_def_mapping_enabled = 0
