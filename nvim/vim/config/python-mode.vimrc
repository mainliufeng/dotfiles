" Python-mode ------------------------------

" don't use linter, we use syntastic for that
" 不使用 Python-Mode 的 linter
let g:pymode_lint_on_write = 0
let g:pymode_lint_signs = 0

" don't fold python code on open
" 打开时不折叠 python 代码
let g:pymode_folding = 0

" don't load rope by default. Change to 1 to use rope
" 不加载rope
let g:pymode_rope = 0

" 使用 virtualenv
let g:pymode_virtualenv=1

" open definitions on same window, and custom mappings for definitions and occurrences
" 不知道干什么的，以后在说
" let g:pymode_rope_goto_definition_bind = ',d'
" let g:pymode_rope_goto_definition_cmd = 'e'
" nmap ,D :tab split<CR>:PymodePython rope.goto()<CR>
" nmap ,o :RopeFindOccurrences<CR>
