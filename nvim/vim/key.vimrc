" fzf
noremap <C-f> :FilesMru<CR>
noremap <C-b> :Buffers<CR>
nnoremap <silent> <C-p> :<C-u>CocFzfList outline<CR>
nnoremap <silent> <C-s> :<C-u>CocList symbols<CR>
noremap ; :Commands<CR>

nnoremap <Leader>q :Quickfix<CR>
nnoremap <Leader>l :Quickfix!<CR>

" vim-floaterm
let g:floaterm_keymap_toggle = '<C-t>'

" coc.nvim
nnoremap <silent> K :call <SID>show_documentation()<CR> 
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)
nmap <leader>rf <Plug>(coc-refactor)
nmap <leader>rn <Plug>(coc-rename)

" EasyMotion
nmap s <Plug>(easymotion-overwin-f2)

" vim-multiple-cursors
let g:multi_cursor_next_key='<C-n>'
let g:multi_cursor_prev_key='<C-p>'
let g:multi_cursor_skip_key='<C-x>'
let g:multi_cursor_quit_key='<Esc>'

" coc-explorer
nmap <leader>e :CocCommand explorer<CR>

" which key
call which_key#register(',', "g:which_key_map")
nnoremap <silent> <leader> :<c-u>WhichKey ','<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual ','<CR>
" nnoremap <localleader> :<c-u>WhichKey  ','<CR>
" vnoremap <localleader> :<c-u>WhichKeyVisual  ','<CR>

" git-fugitive
nmap <leader>gs :G<CR>
nmap <leader>gh :diffget //2<CR>
nmap <leader>gl :diffget //3<CR>
