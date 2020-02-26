" NERDTree -----------------------------

" toggle nerdtree display
" 打开 nerdtree 快捷键
map <F3> :NERDTreeToggle<CR>
nmap <leader>nt :NERDTreeToggle<CR>
nmap <silent> <tab> :NERDTreeToggle<CR>

" open nerdtree with the current file selected
nmap <leader>nf :NERDTreeFind<CR>

" don;t show these file types
" nerdtree 中不显示的文件类型
let NERDTreeIgnore = ['\.pyc$', '\.pyo$', '\.swp$', '__pycache__']

" open a NERDTree automatically when vim starts up
" vim启动时自动打开 nerdtree
" autocmd vimenter * NERDTree

" open a NERDTree automatically when vim starts up if no files were specified
" vim启动时没有指定文件，则自动打开 nerdtree
" autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" close vim if the only window left open is a NERDTree
" 如果只剩 nerdtree 窗口，关闭vim
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" change default arrows
" 更改默认箭头
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'

let g:NERDTreeNaturalSort = 1

