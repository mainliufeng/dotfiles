set timeoutlen=500
let g:which_key_map =  {}

let g:which_key_map.a = {'name': 'Add'}
let g:which_key_map.s = {'name': 'Source'}
let g:which_key_map.n = {'name': 'NerdTree'}
let g:which_key_map.d = {'name': 'Denite'}
let g:which_key_map.t = {'name': 'Terminal'}
let g:which_key_map.c = {'name': 'Comment'}

call which_key#register(',', "g:which_key_map")
nnoremap <silent> <leader> :<c-u>WhichKey ','<CR>
vnoremap <silent> <leader> :<c-u>WhichKeyVisual ','<CR>
" nnoremap <localleader> :<c-u>WhichKey  ','<CR>
" vnoremap <localleader> :<c-u>WhichKeyVisual  ','<CR>

autocmd! FileType which_key
autocmd  FileType which_key set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
