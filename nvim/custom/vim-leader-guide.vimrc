let g:lmap =  {}

let g:lmap.a = {'name': 'Add'}
let g:lmap.s = {'name': 'Source'}
let g:lmap.n = {'name': 'NerdTree'}
let g:lmap.d = {'name': 'Denite'}
let g:lmap.t = {'name': 'Terminal'}
let g:lmap.c = {'name': 'Comment'}

call leaderGuide#register_prefix_descriptions(",", "g:lmap")
nnoremap <localleader> :<c-u>LeaderGuide  ','<CR>
vnoremap <localleader> :<c-u>LeaderGuideVisual  ','<CR>
