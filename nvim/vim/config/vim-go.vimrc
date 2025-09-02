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

" Load .env file if it exists in the current project root
function! LoadEnvFile()
    let l:env_file = findfile('.env', '.;')
    if !empty(l:env_file)
        let l:env_vars = {}
        for l:line in readfile(l:env_file)
            " Skip empty lines and comments
            if l:line =~ '^\s*$' || l:line =~ '^\s*#'
                continue
            endif
            " Parse KEY=VALUE lines
            let l:parts = split(l:line, '=', 1)
            if len(l:parts) == 2
                let l:key = l:parts[0]
                let l:value = substitute(l:parts[1], '^\s*["'']\|["'']\s*$', '', 'g')
                let l:env_vars[l:key] = l:value
            endif
        endfor
        return l:env_vars
    endif
    return {}
endfunction

" Set environment variables before running Go tests
function! SetGoTestEnv()
    let l:env_vars = LoadEnvFile()
    let l:env_string = ''
    for [l:key, l:value] in items(l:env_vars)
        let l:env_string .= l:key . '=' . shellescape(l:value) . ' '
    endfor
    if !empty(l:env_string)
        let g:go_test_prepend = l:env_string
    endif
endfunction

" Automatically load .env before running tests
augroup GoEnvLoader
    autocmd!
    autocmd FileType go call SetGoTestEnv()
    autocmd BufEnter *.go call SetGoTestEnv()
augroup END

" disable mapping
let g:go_def_mapping_enabled = 0
