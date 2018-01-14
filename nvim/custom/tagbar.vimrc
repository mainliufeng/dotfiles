" Tagbar ----------------------------- 

" toggle tagbar display
" tagbar快捷键
map <F4> :TagbarToggle<CR>

" vim启动时自动打开tagbar
autocmd VimEnter * nested :TagbarOpen

" autofocus on tagbar open
" 打开时，自动切换焦点到tagbar
"let g:tagbar_autofocus = 1

" 关闭快捷键中去掉"-"，"-"是window chooser的快捷键
let g:tagbar_map_closefold = ['<kMinus>', 'zc']

" golang tagbar配置
" let g:tagbar_type_go = {
"     \ 'ctagstype': 'go',
"     \ 'kinds' : [
"         \'p:package',
"         \'f:function',
"         \'v:variables',
"         \'t:type',
"         \'c:const'
"     \]
" \}

let g:tagbar_ctags_bin='/usr/local/bin/ctags'
