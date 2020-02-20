" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged_vscode')

" Make sure you use single quotes

" multiple cursors
Plug 'terryma/vim-multiple-cursors'

" Undo Tree
Plug 'mbbill/undotree'

" vim easy motion
Plug 'asvetliakov/vim-easymotion'

" show marks
Plug 'kshenoy/vim-signature'

" auto pair
Plug 'jiangmiao/auto-pairs'

" plist
Plug 'darfink/vim-plist'

" yaml
Plug 'chase/vim-ansible-yaml'

" targets.vim
Plug 'wellle/targets.vim'

" Initialize plugin system
call plug#end()

for f in split(glob('~/.config/nvim/common/*.vimrc'), '\n')
    exe 'source' f
endfor

