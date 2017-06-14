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
Plugin 'vim-airline/vim-airline-themes'

" Python and other languages code checker
Plugin 'scrooloose/syntastic'

" 代码补齐
" Plugin 'Shougo/neocomplete'
" Plugin 'Shougo/neosnippet'
" Plugin 'Shougo/neosnippet-snippets'
Plugin 'davidhalter/jedi-vim'
" Plugin 'Valloric/YouCompleteMe'

" sort python imports using isort
" Plugin 'fisadev/vim-isort'

" 窗口选择器
Plugin 't9md/vim-choosewin'

" colorize all text in the form #rrggbb or #rgb 
" Plugin 'lilydjwg/colorizer'

" 模糊匹配
Plugin 'ctrlpvim/ctrlp.vim'
" 匹配命令
Plugin 'fisadev/vim-ctrlp-cmdpalette'

" vim-go
Plugin 'fatih/vim-go'

" Dash Search
" Plugin 'rizzatti/dash.vim'

" ultisnips
Plugin 'SirVer/ultisnips'

" snippets
Plugin 'honza/vim-snippets'

" scala
" Plugin 'derekwyatt/vim-scala'

" vim with tmux
" Plugin 'benmills/vimux'

" solarized
Plugin  'altercation/vim-colors-solarized'

" multiple cursors
Plugin 'terryma/vim-multiple-cursors'

" large file
Plugin 'LargeFile'



" ============================================================================
" Install plugins the first time vim runs

if iCanHazVundle == 0
    echo "Installing Bundles, please ignore key map error messages"
    echo ""
    :BundleInstall
endif


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
