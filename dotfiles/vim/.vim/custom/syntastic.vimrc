" Syntastic ------------------------------

" show list of errors and warnings on the current file
nmap <leader>e :Errors<CR>

" check also when just opened the file
" 打开文件时检查代码
let g:syntastic_check_on_open = 1

" don't put icons on the sign column (it hides the vcs status icons of signify)
" 关闭左侧检查结果标志
" let g:syntastic_enable_signs = 0

" custom icons (enable them if you use a patched font, and enable the previous setting)
" 自定义图标
let g:syntastic_error_symbol = '✗'
let g:syntastic_warning_symbol = '⚠'
let g:syntastic_style_error_symbol = '✗'
let g:syntastic_style_warning_symbol = '⚠'

" Python Checker flake8, pyflakes, pylint and a native python
" let g:syntastic_python_checkers=['pylint']

let g:loaded_syntastic_java_javac_checker = 1
