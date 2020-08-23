" split window navigation
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l

" split window resize
noremap <silent> <C-Left> :vertical resize -3<CR>
noremap <silent> <C-Right> :vertical resize +3<CR>
noremap <silent> <C-Up> :resize -3<CR>
noremap <silent> <C-Down> :resize +3<CR>

" Ctrl+w R  swap splits

map <leader>th <C-w>t<C-w>H
map <leader>tk <C-w>t<C-w>K

tnoremap <leader>n <C-\><C-n>
