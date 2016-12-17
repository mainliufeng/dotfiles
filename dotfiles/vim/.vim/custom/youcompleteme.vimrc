" " YouCompleteMe ------------------------------
" let g:ycm_autoclose_preview_window_after_completion=1
" let g:ycm_autoclose_preview_window_after_insertion=1
" let g:ycm_min_num_of_chars_for_completion = 1
" let g:ycm_min_num_identifier_candidate_chars = 0
" let g:ycm_auto_trigger = 0
" let g:ycm_key_list_select_completion = []
" let g:ycm_key_list_previous_completion = []
" 
" set completeopt=longest,menu "让Vim的补全菜单行为与一般IDE一致(参考VimTip1228)
" nnoremap <leader>g :YcmCompleter GoToDefinitionElseDeclaration<CR>
" inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>" "回车即选中当前项
" inoremap <expr> <C-j> pumvisible() ? "\<C-n>" : "\<C-X><C-O><C-P>" "弹出补全窗口，和选中下一个
" inoremap <expr> <C-k> pumvisible() ? "\<C-p>" : "\<C-k>" "选中上一个
