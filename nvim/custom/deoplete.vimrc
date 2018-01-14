let g:deoplete#enable_at_startup = 1
let g:deoplete#sources#jedi#server_timeout = 10
let g:deoplete#sources#jedi#statement_length = 50
let g:deoplete#sources#jedi#enable_cache = 1
let g:deoplete#sources#jedi#show_docstring = 1

inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-X><C-O><C-P>" "弹出补全窗口，和选中下一个
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>" "选中上一个
