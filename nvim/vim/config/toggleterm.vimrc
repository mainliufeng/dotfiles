autocmd TermEnter term://*toggleterm#*
      \ tnoremap <silent><c-\> <Cmd>exe v:count1 . "ToggleTerm direction=float"<CR>
