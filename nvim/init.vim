" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')

" Make sure you use single quotes

" Better file browser
" 文件列表
Plug 'scrooloose/nerdtree'

" lf
Plug 'ptzz/lf.vim'
Plug 'rbgrouleff/bclose.vim'

" NerdTree Git
Plug 'Xuyuanp/nerdtree-git-plugin'

" 打开的文件中显示git状态
Plug 'airblade/vim-gitgutter'

" An efficient fuzzy finder that helps to locate files, buffers, mrus, gtags, etc. on the fly.
Plug 'Yggdroot/LeaderF', { 'do': './install.sh' }

" Python-mode
Plug 'klen/python-mode'

" lightline
Plug 'itchyny/lightline.vim'

" code completion
Plug 'neoclide/coc.nvim', {'branch': 'release'}

" neomake
Plug 'neomake/neomake'

" 窗口选择器
Plug 't9md/vim-choosewin'

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

" Nerdcommenter
Plug 'scrooloose/nerdcommenter'

" vim-tmux-navigator
Plug 'christoomey/vim-tmux-navigator'

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

" git-messenger.vim
Plug 'rhysd/git-messenger.vim'

" Initialize plugin system
call plug#end()

for f in split(glob('~/.config/nvim/common/*.vimrc'), '\n')
    exe 'source' f
endfor
for f in split(glob('~/.config/nvim/nvim/*.vimrc'), '\n')
    exe 'source' f
endfor
