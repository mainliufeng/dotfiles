" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')

" Make sure you use single quotes

" Better file browser
" 文件列表
Plug 'scrooloose/nerdtree'

" NerdTree Git
Plug 'Xuyuanp/nerdtree-git-plugin'

" 打开的文件中显示git状态
Plug 'airblade/vim-gitgutter'

" Class/module browser
" 类/模块浏览器
Plug 'majutsushi/tagbar'

" Python-mode
Plug 'klen/python-mode'

" Airline
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" Lightline
" Plug 'itchyny/lightline.vim'

if has('nvim')
  Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
else
  Plug 'Shougo/deoplete.nvim'
  Plug 'roxma/nvim-yarp'
  Plug 'roxma/vim-hug-neovim-rpc'
endif
Plug 'zchee/deoplete-jedi'
Plug 'artur-shaik/vim-javacomplete2'

" sort python imports using isort
" Plug 'fisadev/vim-isort'

" Asynchronous Lint Engine
Plug 'w0rp/ale'

" 窗口选择器
Plug 't9md/vim-choosewin'

" colorize all text in the form #rrggbb or #rgb 
" Plugin 'lilydjwg/colorizer'

" Dark powered asynchronous unite all interfaces for Neovim/Vim8
Plug 'Shougo/denite.nvim'

" vim-go
Plug 'fatih/vim-go'

" Dash Search
" Plug 'rizzatti/dash.vim'

" ultisnips
Plug 'SirVer/ultisnips'

" snippets
Plug 'honza/vim-snippets'

" scala
" Plug 'derekwyatt/vim-scala'

" vim with tmux
" Plug 'benmills/vimux'

" solarized
Plug  'altercation/vim-colors-solarized'

" multiple cursors
Plug 'terryma/vim-multiple-cursors'

" large file
" Plug 'LargeFile'

" Undo Tree
Plug 'mbbill/undotree'

" vim easy motion
Plug 'easymotion/vim-easymotion'

" show marks
Plug 'kshenoy/vim-signature'

" auto pair
Plug 'jiangmiao/auto-pairs'

" markdown preview
Plug 'JamshedVesuna/vim-markdown-preview'

" supertab
Plug 'ervandew/supertab'

" Guide key
Plug 'hecal3/vim-leader-guide'

" Nerdcommenter
Plug 'scrooloose/nerdcommenter'

" remenberall
" Plug 'urbainvaes/vim-remembrall'

" jedi-vim
Plug 'davidhalter/jedi-vim'

" vim-tmux-navigator
Plug 'christoomey/vim-tmux-navigator'

" plist
Plug 'darfink/vim-plist'

" Initialize plugin system
call plug#end()

for f in split(glob('~/.config/nvim/custom/*.vimrc'), '\n')
    exe 'source' f
endfor
