" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')

" Make sure you use single quotes

" Shorthand notation; fetches https://github.com/junegunn/vim-easy-align
Plug 'junegunn/vim-easy-align'

" Any valid git URL is allowed
Plug 'https://github.com/junegunn/vim-github-dashboard.git'

" Multiple Plug commands can be written in a single line using | separators
Plug 'SirVer/ultisnips' | Plug 'honza/vim-snippets'

" On-demand loading
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

" Using a non-master branch
Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }

" Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
Plug 'fatih/vim-go', { 'tag': '*' }

" Plugin options
Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

" Plugin outside ~/.vim/plugged with post-update hook
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }

" Unmanaged plugin (manually installed and updated)
Plug '~/my-prototype-plugin'

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

" Python and other languages code checker
Plug 'scrooloose/syntastic'

" 代码补齐
" Plug 'Shougo/neocomplete'
" Plug 'Shougo/neosnippet'
" Plug 'Shougo/neosnippet-snippets'
Plug 'davidhalter/jedi-vim'
" Plug 'Valloric/YouCompleteMe'

" sort python imports using isort
" Plug 'fisadev/vim-isort'

" 窗口选择器
Plug 't9md/vim-choosewin'

" colorize all text in the form #rrggbb or #rgb 
" Plugin 'lilydjwg/colorizer'

" 模糊匹配
Plug 'ctrlpvim/ctrlp.vim'
" 匹配命令
Plug 'fisadev/vim-ctrlp-cmdpalette'

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

" Initialize plugin system
call plug#end()


:source ~/.vim/custom/all.vimrc
:source ~/.vim/custom/abbreviations.vimrc
:source ~/.vim/custom/airline.vimrc
:source ~/.vim/custom/all.vimrc
:source ~/.vim/custom/ctrlp.vimrc
:source ~/.vim/custom/git-gutter.vimrc
:source ~/.vim/custom/jedi-vim.vimrc
:source ~/.vim/custom/neocomplete.vimrc
:source ~/.vim/custom/nerdtree.vimrc
:source ~/.vim/custom/python-mode.vimrc
:source ~/.vim/custom/syntastic.vimrc
:source ~/.vim/custom/tagbar.vimrc
:source ~/.vim/custom/ultisnips.vimrc
:source ~/.vim/custom/vim_isort.vimrc
:source ~/.vim/custom/window-chooser.vimrc
:source ~/.vim/custom/youcompleteme.vimrc
:source ~/.vim/custom/json-format.vimrc
