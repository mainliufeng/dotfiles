" ============================================================================
" Vundle initialization
" Avoid modify this section, unless you are very sure of what you are doing

" no vi-compatible
set nocompatible

" Setting up Vundle - the vim plugin bundler
let iCanHazVundle=1
let vundle_readme=expand('~/.vim/bundle/vundle/README.md')
if !filereadable(vundle_readme)
    echo "Installing Vundle..."
    echo ""
    silent !mkdir -p ~/.vim/bundle
    silent !git clone https://github.com/gmarik/vundle ~/.vim/bundle/vundle
    let iCanHazVundle=0
endif

filetype off

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" let Vundle manage Vundle
Plugin 'VundleVim/Vundle.vim'

" ============================================================================
" Active plugins
" You can disable or add new ones here:

" Better file browser
" 文件列表
Plugin 'scrooloose/nerdtree'

" NerdTree Git
Plugin 'Xuyuanp/nerdtree-git-plugin'

" 打开的文件中显示git状态
Plugin 'airblade/vim-gitgutter'

" Class/module browser
" 类/模块浏览器
Plugin 'majutsushi/tagbar'

" Python-mode
Plugin 'klen/python-mode'

" Airline
Plugin 'bling/vim-airline'

" Python and other languages code checker
Plugin 'scrooloose/syntastic'

" 代码补齐
Plugin 'davidhalter/jedi-vim'

" sort python imports using isort
Plugin 'fisadev/vim-isort'

" 窗口选择器
Plugin 't9md/vim-choosewin'

" colorize all text in the form #rrggbb or #rgb 
Plugin 'lilydjwg/colorizer'



" ============================================================================
" Install plugins the first time vim runs

if iCanHazVundle == 0
    echo "Installing Bundles, please ignore key map error messages"
    echo ""
    :BundleInstall
endif

" ============================================================================
" Vim settings and mappings
" You can edit them as you wish

" allow plugins by file type (required for plugins!)
filetype plugin on
filetype indent on

" tabs and spaces handling
set expandtab
set tabstop=4
set softtabstop=4
set shiftwidth=4

" 删除键可以删除当前insert mode没有插入的内容（默认不能删除）
set backspace=start,eol,indent

" tab length exceptions on some file types
autocmd FileType html setlocal shiftwidth=2 tabstop=2 softtabstop=2
autocmd FileType javascript setlocal shiftwidth=2 tabstop=2 softtabstop=2

" always show status bar
set ls=2

" incremental search
set incsearch
" highlighted search results
set hlsearch

" syntax highlight on
syntax on

" show line numbers
set nu



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
let g:tagbar_type_go = {
    \ 'ctagstype': 'go',
    \ 'kinds' : [
        \'p:package',
        \'f:function',
        \'v:variables',
        \'t:type',
        \'c:const'
    \]
\}



" NERDTree ----------------------------- 

" toggle nerdtree display
" 打开 nerdtree 快捷键
map <F3> :NERDTreeToggle<CR>

" open nerdtree with the current file selected
nmap ,t :NERDTreeFind<CR>

" don;t show these file types
" nerdtree 中不显示的文件类型
let NERDTreeIgnore = ['\.pyc$', '\.pyo$']

" open a NERDTree automatically when vim starts up
" vim启动时自动打开 nerdtree
" autocmd vimenter * NERDTree

" open a NERDTree automatically when vim starts up if no files were specified
" vim启动时没有指定文件，则自动打开 nerdtree
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

" close vim if the only window left open is a NERDTree
" 如果只剩 nerdtree 窗口，关闭vim
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" change default arrows
" 更改默认箭头
let g:NERDTreeDirArrowExpandable = '▸'
let g:NERDTreeDirArrowCollapsible = '▾'



" Airline ------------------------------

let g:airline_powerline_fonts = 0
let g:airline_theme = 'bubblegum'
let g:airline#extensions#whitespace#enabled = 0

" to use fancy symbols for airline, uncomment the following lines and use a patched font (more info on the README.rst)
"if !exists('g:airline_symbols')
"   let g:airline_symbols = {}
"endif
"let g:airline_left_sep = '⮀'
"let g:airline_left_alt_sep = '⮁'
"let g:airline_right_sep = '⮂'
"let g:airline_right_alt_sep = '⮃'
"let g:airline_symbols.branch = '⭠'
"let g:airline_symbols.readonly = '⭤'
"let g:airline_symbols.linenr = '⭡'



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
" let g:pymode_rope_goto_definition_bind = ',d'
" let g:pymode_rope_goto_definition_cmd = 'e'
" nmap ,D :tab split<CR>:PymodePython rope.goto()<CR>
" nmap ,o :RopeFindOccurrences<CR>



" vim-jedi ------------------------------

" Disable auto initialization
" let g:jedi#auto_initialization = 0

" make jedi-vim use tabs when going to a definition
let g:jedi#use_tabs_not_buffers = 1

" use VIM-splits
let g:jedi#use_splits_not_buffers = "left"

" 不使用 . 触发补齐
" let g:jedi#popup_on_dot = 0

" Jedi selects the first line of the completion menu: for a better typing-flow
" and usually saves one keypress
" 自动选中第一个提示
" let g:jedi#popup_select_first = 0

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



" vim_isort ------------------------------

" isort快捷键，''表示禁用
let g:vim_isort_map = ''



" Window Chooser ------------------------------

" mapping
" 快捷键 - 
nmap  -  <Plug>(choosewin)

" show big letters
let g:choosewin_overlay_enable = 1



" Git Gutter ---------------------------------

" 更新时间250毫秒
set updatetime=250

" 不使用快捷键
let g:gitgutter_map_keys = 0

