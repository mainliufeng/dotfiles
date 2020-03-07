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
augroup tab_length
    autocmd!
    autocmd FileType html setlocal shiftwidth=2 tabstop=2 softtabstop=2
    autocmd FileType md setlocal shiftwidth=2 tabstop=2 softtabstop=2
    autocmd FileType yaml setlocal shiftwidth=2 tabstop=2 softtabstop=2
    autocmd FileType xml setlocal shiftwidth=4 tabstop=4 softtabstop=4
    autocmd FileType javascript setlocal shiftwidth=2 tabstop=2 softtabstop=2
    autocmd FileType java setlocal shiftwidth=4 tabstop=4 softtabstop=4
    autocmd FileType scala setlocal shiftwidth=2 tabstop=2 softtabstop=2
    autocmd FileType python setlocal shiftwidth=2 tabstop=2 softtabstop=2
augroup END

" always show status bar
set ls=2

" incremental search
set incsearch
" highlighted search results
set hlsearch

" syntax highlight on
syntax on

" show line relative and absolute line numbers
set rnu
set nu



" Local ------------------------------
" 设置leader
let mapleader = ","
let maplocalleader = ","

" Font
set guifont=Menlo\ for\ Powerline:h12

if &term =~ '256color'
    " disable Background Color Erase (BCE) so that color schemes
    " render properly when inside 256-color tmux and GNU screen.
    " see also http://sunaku.github.io/vim-256color-bce.html
    set t_ut=
endif

set t_8f=^[[38;2;%lu;%lu;%lum        " set foreground color
set t_8b=^[[48;2;%lu;%lu;%lum        " set background color
set t_Co=256                         " Enable 256 colors
set termguicolors                    " Enable GUI colors for the terminal to get truecolor

" Local --------------------------------

" map jk kj esc
imap jk <Esc>
imap kj <Esc>

onoremap p i(
onoremap b /return<cr>

" 打开vimrc，source vimrc快捷键
" nnoremap <leader>rc :vsplit $MYVIMRC<cr>
nnoremap <leader>src :source $MYVIMRC<cr>

" 在word外加符号
nnoremap <leader>a" viw<esc>a"<esc>hbi"<esc>lel
nnoremap <leader>a' viw<esc>a'<esc>hbi'<esc>lel
nnoremap <leader>a( viw<esc>a)<esc>hbi(<esc>lel
nnoremap <leader>a) viw<esc>a)<esc>hbi(<esc>lel
nnoremap <leader>a[ viw<esc>a]<esc>hbi[<esc>lel
nnoremap <leader>a] viw<esc>a]<esc>hbi[<esc>lel
nnoremap <leader>a{ viw<esc>a}<esc>hbi{<esc>lel
nnoremap <leader>a} viw<esc>a}<esc>hbi{<esc>lel

" Autocommand

" html
" augroup html_file
"     autocmd!
"     autocmd BufWritePre,BufRead *.html :normal gg=G
"     autocmd BufNewFile,BufRead *.html setlocal nowrap
" augroup END

" highlight current line in normal mode
autocmd InsertLeave,WinEnter * set cursorline
autocmd InsertEnter,WinLeave * set nocursorline

let g:python3_host_prog = '/usr/local/bin/python3'

" popup menu color
highlight Pmenu ctermbg=black guibg=black

" get escape back in terminal
"tnoremap <Esc> <C-\><C-n>
