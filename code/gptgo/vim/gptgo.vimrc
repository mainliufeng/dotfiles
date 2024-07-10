if exists('g:loaded_gptgo')
    finish
endif
let g:loaded_gptgo = 1

function! s:RequireGptGo(host) abort
    return jobstart(['gptgo'], {'rpc': v:true})
endfunction

call remote#host#Register('gptgo', 'x', function('s:RequireGptGo'))
call remote#host#RegisterPlugin('gptgo', '0', [
          \ {'type': 'command', 'name': 'GptGoNewBuffer', 'sync': 1, 'opts': {}},
          \ {'type': 'command', 'name': 'GptGoContinue', 'sync': 1, 'opts': {}},
          \ {'type': 'function', 'name': 'GptGoSendInput', 'sync': 1, 'opts': {}},
         \ ])

" vim:ts=4:sw=4:et
