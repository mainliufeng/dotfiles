let g:fzf_layout = { 'window': { 'width': 0.9, 'height': 0.6 } }
let g:fzf_buffers_jump = 1

noremap <C-f> :FilesMru<CR>
noremap <C-b> :Buffers<CR>
noremap <C-p> :BTags<CR>
noremap <C-m> :Commands<CR>
noremap <C-g> :BCommits<CR>

noremap <leader>fb :<C-U><C-R>=printf("Buffers")<CR><CR>
noremap <leader>fl :<C-U><C-R>=printf("Lines")<CR><CR>
noremap <leader>ff :<C-U><C-R>=printf("FilesMru")<CR><CR>
