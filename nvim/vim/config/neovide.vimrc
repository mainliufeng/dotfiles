let g:neovide_cursor_animation_length=0
let g:neovide_input_use_logo = v:true
let g:neovide_scroll_animation_length = 0
set guifont=Hack\ Nerd\ Font\ Mono:h16

if exists('g:neovide')
    " Neovide forwards keys to Neovim instead of installing macOS paste
    " shortcuts, so wire GUI paste explicitly for editor and terminal modes.
    nnoremap <silent> <D-v> "+P
    vnoremap <silent> <D-v> "+P
    inoremap <silent> <D-v> <C-r>+
    cnoremap <silent> <D-v> <C-r>+

    tnoremap <silent> <D-v> <C-\><C-n>"+Pi
    tnoremap <silent> <C-v> <C-\><C-n>"+Pi
    tnoremap <silent> <C-S-v> <C-\><C-n>"+Pi
endif
