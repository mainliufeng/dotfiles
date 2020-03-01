nmap <Leader>gm <Plug>(git-messenger)
let g:git_messenger_always_into_popup = v:true

function! s:setup_git_messenger_popup() abort
    " Your favorite configuration here

    " For example, set go back/forward history to <C-o>/<C-i>
    nmap <buffer><C-h> o
    nmap <buffer><C-l> O
endfunction
autocmd FileType gitmessengerpopup call <SID>setup_git_messenger_popup()
