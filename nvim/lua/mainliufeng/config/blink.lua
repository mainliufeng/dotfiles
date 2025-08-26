-- blink.cmp configuration
-- This file provides additional configuration for blink.cmp
-- Main configuration is in init.lua

require('blink.cmp').setup({
    keymap = {
        preset = 'none',
        ['<C-j>'] = { 'select_next', 'fallback' },
        ['<C-k>'] = { 'select_prev', 'fallback' },
        ['<CR>'] = { 'accept', 'fallback' },
        ['<C-Space>'] = { 'show', 'hide' },
        ['<Tab>'] = { 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'snippet_backward', 'fallback' },
        ['<C-b>'] = { 'scroll_documentation_up', 'fallback' },
        ['<C-f>'] = { 'scroll_documentation_down', 'fallback' },
        ['<C-e>'] = { 'hide', 'fallback' },
    },
    
    appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = 'mono'
    },
    
    sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
        providers = {
            lsp = {
                name = 'LSP',
                module = 'blink.cmp.sources.lsp',
                enabled = true,
                score_offset = 90,
            },
            path = {
                name = 'Path',
                module = 'blink.cmp.sources.path',
                enabled = true,
                score_offset = 3,
            },
            snippets = {
                name = 'Snippets',
                module = 'blink.cmp.sources.snippets',
                enabled = true,
                score_offset = 85,
            },
            buffer = {
                name = 'Buffer',
                module = 'blink.cmp.sources.buffer',
                enabled = true,
                score_offset = 5,
            },
        },
    },
    
    completion = {
        accept = {
            auto_brackets = {
                enabled = true,
            },
        },
        menu = {
            border = 'none',
            draw = {
                treesitter = { 'lsp' },
                columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
            }
        },
        documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
            update_delay_ms = 50,
            window = {
                border = 'none',
                max_width = 80,
                max_height = 20,
            }
        },
        ghost_text = {
            enabled = true,
        }
    },
    
    signature = {
        enabled = true,
        trigger = {
            blocked_trigger_characters = {},
            blocked_retrigger_characters = {},
            show_delay_ms = 200,
            hide_delay_ms = 200,
        },
        window = {
            border = 'none',
        }
    }
})