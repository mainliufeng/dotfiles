" CtrlP -----------------------------------

" 快捷键和命令（默认就是这个设置）
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'

" 搜索目录，.git所在目录，当前文件所在目录
let g:ctrlp_working_path_mode = 'ra'

" 忽略文件和目录
let g:ctrlp_custom_ignore = {
            \ 'dir':  '\v[\/](\.git|\.hg|\.svn)$',
            \ 'file': '\.pyc$\|\.pyo$',
            \ }

" 忽略.gitignore中的文件
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

" 搜索当前文件中的tags (symbols)
nmap ,g :CtrlPBufTag<CR>
" 所有文件中的tags (symbols)
nmap ,G :CtrlPBufTagAll<CR>
" 搜索文件中的代码
nmap ,f :CtrlPLine<CR>
" 搜索Vim命令
nmap ,c :CtrlPCmdPalette<CR>

" 不改变当前工作目录
let g:ctrlp_working_path_mode = 0
