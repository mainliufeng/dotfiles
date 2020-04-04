" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')

" Make sure you use single quotes

" Better file browser
" 文件列表
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'

" fasd
Plug 'tomtom/tlib_vim'
Plug 'amiorin/vim-fasd'

" lf
Plug 'ptzz/lf.vim'
Plug 'rbgrouleff/bclose.vim'

" 打开的文件中显示git状态
Plug 'airblade/vim-gitgutter'

" vim-fugitive
Plug 'tpope/vim-fugitive'

" fzf
Plug '/usr/local/opt/fzf'
Plug 'junegunn/fzf.vim'
Plug 'tweekmonster/fzf-filemru'
Plug 'fszymanski/fzf-quickfix', {'on': 'Quickfix'}
Plug 'antoinemadec/coc-fzf'

" Python-mode
Plug 'klen/python-mode'

" Airline
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" code completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" ale
Plug 'dense-analysis/ale'

" ultisnips
Plug 'SirVer/ultisnips'

" snippets
Plug 'honza/vim-snippets'

" solarized
Plug  'altercation/vim-colors-solarized'

" multiple cursors
Plug 'terryma/vim-multiple-cursors'

" Undo Tree
Plug 'mbbill/undotree'

" vim easy motion
Plug 'easymotion/vim-easymotion'

" show marks
Plug 'kshenoy/vim-signature'

" auto pair
Plug 'jiangmiao/auto-pairs'

" Guide key
Plug 'liuchengxu/vim-which-key'

" plist
Plug 'darfink/vim-plist'

" yaml
Plug 'chase/vim-ansible-yaml'

" targets.vim
Plug 'wellle/targets.vim'

" markdown
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install'  }

" vim-go
Plug 'fatih/vim-go', { 'do': ':GoUpdateBinaries' }

" tagbar
Plug 'liuchengxu/vista.vim'

" golang debug
Plug 'sebdah/vim-delve'

" float terminal
Plug 'voldikss/vim-floaterm'

" Initialize plugin system
call plug#end()

for f in split(glob('~/.config/nvim/plugin/*.vimrc'), '\n')
    exe 'source' f
endfor
for f in split(glob('~/.config/nvim/vim/*.vimrc'), '\n')
    exe 'source' f
endfor
