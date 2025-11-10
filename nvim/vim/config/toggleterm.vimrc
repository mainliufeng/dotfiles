" Snacks terminal keymaps (replaces toggleterm)
augroup SnacksTerminalKeymaps
    autocmd!
    autocmd TermEnter term://* if &filetype ==# 'snacks_terminal' |
                \ tnoremap <silent><buffer> <C-\> <Cmd>lua require('mainliufeng.config.terminal').toggle((vim.b.snacks_terminal and vim.b.snacks_terminal.id) or 1)<CR> |
            \ endif
augroup END
