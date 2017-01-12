" vim-jedi ------------------------------

" Disable auto initialization
" let g:jedi#auto_initialization = 0

" make jedi-vim use tabs when going to a definition
let g:jedi#use_tabs_not_buffers = 1

" use VIM-splits
let g:jedi#use_splits_not_buffers = "left"

" 不使用 . 触发补齐
let g:jedi#popup_on_dot = 0

" Jedi selects the first line of the completion menu: for a better typing-flow
" and usually saves one keypress
" 自动选中第一个提示
let g:jedi#popup_select_first = 0

" Jedi displays function call signatures in insert mode in real-time,
" highlighting the current argument. The call signatures can be displayed as a
" pop-up in the buffer (set to 1, the default), which has the advantage of
" being easier to refer to, or in Vim's command line aligned with the function
" call (set to 2), which can improve the integrity of Vim's undo history.
let g:jedi#show_call_signatures = "1"

" Here are a few more defaults for actions, read the docs (:help jedi-vim) to
" get more information. If you set them to "", they are not assigned.

" 跳到代码位置 
let g:jedi#goto_command = "<leader>d"

" Goto assignments
" 跳到当前文件中的定义
let g:jedi#goto_assignments_command = "<leader>g"

" 跳到定义 
let g:jedi#goto_definitions_command = ""

" Show Documentation/Pydoc
" 显示文档
let g:jedi#documentation_command = "K"

" shows all the usages of a name
" 显示用法
let g:jedi#usages_command = "<leader>n"

" 补全快捷键
let g:jedi#completions_command = "<C-j>"

" 重命名
let g:jedi#rename_command = "<leader>r"

" if you don't want completion, but all the other features
" let g:jedi#completions_enabled = 0
"

inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-X><C-O><C-P>" "弹出补全窗口，和选中下一个
inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>" "选中上一个
