" Run xrdb whenever Xdefaults or Xresources are updated.
autocmd BufWritePost *Xresources,*Xdefaults !xrdb %

" sxhkd reload config (see: man sxhkd)
autocmd BufWritePost *sxhkdrc !pkill -USR1 sxhkd
