set timeoutlen=500
let g:which_key_map =  {}

let g:which_key_map.f = {'name': 'Fzf'}

autocmd! FileType which_key
autocmd  FileType which_key set laststatus=0 noshowmode noruler
  \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
