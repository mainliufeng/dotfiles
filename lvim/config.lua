--[[
 THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT
 `lvim` is the global options object
]]

-- vim options
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.relativenumber = true
vim.opt.clipboard = "unnamedplus" -- allows neovim to access the system clipboard
vim.opt.wrap = true

-- general
lvim.log.level      = "info"
lvim.format_on_save = {
    enabled = true,
    pattern = "*.lua,*.go",
    timeout = 1000,
}
-- to disable icons and use a minimalist setup, uncomment the following
-- lvim.use_icons = false

-- keymappings <https://www.lunarvim.org/docs/configuration/keybindings>
-- add your own keymapping
lvim.keys.term_mode["<C-h>"] = false
lvim.keys.term_mode["<C-j>"] = false
lvim.keys.term_mode["<C-k>"] = false
lvim.keys.term_mode["<C-l>"] = false

-- 快捷键
lvim.keys.normal_mode["<C-c>"] = ":ChatGPT<CR>"
lvim.keys.visual_mode["<C-e>"] = "<cmd>lua require'chatgpt'.edit_with_instructions()<CR>"
lvim.keys.normal_mode["s"]     = ":HopWord<cr>"
lvim.keys.normal_mode["<C-f>"] = ":Telescope find_files hidden=true no_ignore=true<CR>"
lvim.keys.normal_mode["<C-b>"] = ":Telescope buffers initial_mode=insert<CR>"
lvim.keys.normal_mode["<C-p>"] = ":lua require(\'telescope.builtin\').lsp_document_symbols()<CR>"
lvim.keys.normal_mode["<C-s>"] = ":lua require(\'telescope.builtin\').lsp_dynamic_workspace_symbols()<CR>"
lvim.keys.normal_mode[";"]     = ":Telescope commands<CR>"
lvim.keys.normal_mode["<F3>"]  = ":NvimTreeFindFileToggle<CR>"
lvim.keys.normal_mode["<F4>"]  = "<cmd>lua require'dapui'.toggle()<CR>"
lvim.keys.normal_mode["<F5>"]  = "<cmd>lua require'dap'.continue()<CR>"
lvim.keys.normal_mode["<F10>"] = "<cmd>lua require'dap'.step_over()<CR>"
lvim.keys.normal_mode["<F11>"] = "<cmd>lua require'dap'.step_into()<CR>"
lvim.keys.normal_mode["<F12>"] = "<cmd>lua require'dap'.step_out()<CR>"
-- 中捷键
require "which-key".register({
    ["<space>"] = {
        a = { "<cmd>Alpha<CR>", "Dashboard(alpha)" },
        p = { "<cmd>Telescope projects<CR>", "Projects" },
        f = { "<cmd>Telescope find_files hidden=true no_ignore=true<cr>", "Finds" },
        g = { "<cmd>Telescope live_grep<cr>", "Live grep" },
        b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
        c = { "<cmd>BufferKill<CR>", "Close Buffer" },
    },
})
require "which-key".register({
    ["<space>"] = {
        t = { "<cmd>'<,'>ToggleTermSendVisualSelection<CR>", "Run visual selection" },
    },
}, { mode = "v" })
-- 慢捷键
lvim.leader                            = ","
lvim.builtin.which_key.mappings.d["T"] = { "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<CR>",
    "Breakpoint condition: " }
lvim.builtin.which_key.mappings["D"]   = {
    name = "Diagnostics",
    t = { "<cmd>TroubleToggle<cr>", "trouble" },
    w = { "<cmd>TroubleToggle workspace_diagnostics<cr>", "workspace" },
    d = { "<cmd>TroubleToggle document_diagnostics<cr>", "document" },
    q = { "<cmd>TroubleToggle quickfix<cr>", "quickfix" },
    l = { "<cmd>TroubleToggle loclist<cr>", "loclist" },
    r = { "<cmd>TroubleToggle lsp_references<cr>", "references" },
}

-- lvim.keys.normal_mode["<S-l>"] = ":BufferLineCycleNext<CR>"
-- lvim.keys.normal_mode["<S-h>"] = ":BufferLineCyclePrev<CR>"

-- -- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["W"] = { "<cmd>noautocmd w<cr>", "Save without formatting" }
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }

-- -- Change theme settings
lvim.colorscheme = 'gruvbox'
-- lvim.colorscheme = 'kanagawa'
lvim.transparent_window = true

lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

lvim.builtin.telescope.defaults.layout_config.width = 0.95
lvim.builtin.telescope.defaults.path_display        = { "truncate" }
local actions                                       = require('telescope.actions')
lvim.builtin.telescope.defaults.mappings.i["<C-j>"] = actions.move_selection_next
lvim.builtin.telescope.defaults.mappings.i["<C-k>"] = actions.move_selection_previous

-- Automatically install missing parsers when entering buffer
lvim.builtin.treesitter.auto_install = true

-- lvim.builtin.treesitter.ignore_install = { "haskell" }

-- -- generic LSP settings <https://www.lunarvim.org/docs/languages#lsp-support>

-- --- disable automatic installation of servers
-- lvim.lsp.installer.setup.automatic_installation = false

-- ---configure a server manually. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---see the full default list `:lua =lvim.lsp.automatic_configuration.skipped_servers`
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)

-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---`:LvimInfo` lists which server(s) are skipped for the current filetype
-- lvim.lsp.automatic_configuration.skipped_servers = vim.tbl_filter(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>
-- lvim.lsp.on_attach_callback = function(client, bufnr)
--   local function buf_set_option(...)
--     vim.api.nvim_buf_set_option(bufnr, ...)
--   end
--   --Enable completion triggered by <c-x><c-o>
--   buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
-- end

-- -- linters and formatters <https://www.lunarvim.org/docs/languages#lintingformatting>
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
    {
        command = "goimports",
        filetypes = { "go" },
    },
}
local linters = require "lvim.lsp.null-ls.linters"
linters.setup {
    { command = "golangci_lint" },
}

-- -- Additional Plugins <https://www.lunarvim.org/docs/plugins#user-plugins>
lvim.plugins = {
    {
        "jackMort/ChatGPT.nvim",
        event = "VeryLazy",
        config = function()
            require("chatgpt").setup({
                api_key_cmd = nil,
                yank_register = "+",
                edit_with_instructions = {
                    diff = false,
                    keymaps = {
                        close = "<C-c>",
                        accept = "<C-y>",
                        toggle_diff = "<C-d>",
                        toggle_settings = "<C-o>",
                        cycle_windows = "<Tab>",
                        use_output_as_input = "<C-i>",
                    },
                },
                chat = {
                    welcome_message = WELCOME_MESSAGE,
                    loading_text = "Loading, please wait ...",
                    question_sign = "",
                    answer_sign = "ﮧ",
                    max_line_length = 120,
                    sessions_window = {
                        border = {
                            style = "rounded",
                            text = {
                                top = " Sessions ",
                            },
                        },
                        win_options = {
                            winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                        },
                    },
                    keymaps = {
                        close = { "<C-c>" },
                        yank_last = "<C-y>",
                        yank_last_code = "<C-k>",
                        scroll_up = "<C-u>",
                        scroll_down = "<C-d>",
                        new_session = "<C-n>",
                        cycle_windows = "<Tab>",
                        cycle_modes = "<C-f>",
                        select_session = "<Space>",
                        rename_session = "r",
                        delete_session = "d",
                        draft_message = "<C-d>",
                        toggle_settings = "<C-o>",
                        toggle_message_role = "<C-r>",
                        toggle_system_role_open = "<C-s>",
                    },
                },
                popup_layout = {
                    default = "right",
                    center = {
                        width = "80%",
                        height = "80%",
                    },
                    right = {
                        width = "30%",
                        width_settings_open = "50%",
                    },
                },
                popup_window = {
                    border = {
                        highlight = "FloatBorder",
                        style = "rounded",
                        text = {
                            top = " ChatGPT ",
                        },
                    },
                    win_options = {
                        wrap = true,
                        linebreak = true,
                        foldcolumn = "1",
                        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                    },
                    buf_options = {
                        filetype = "markdown",
                    },
                },
                system_window = {
                    border = {
                        highlight = "FloatBorder",
                        style = "rounded",
                        text = {
                            top = " SYSTEM ",
                        },
                    },
                    win_options = {
                        wrap = true,
                        linebreak = true,
                        foldcolumn = "2",
                        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                    },
                },
                popup_input = {
                    prompt = "  ",
                    border = {
                        highlight = "FloatBorder",
                        style = "rounded",
                        text = {
                            top_align = "center",
                            top = " Prompt ",
                        },
                    },
                    win_options = {
                        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                    },
                    submit = "<C-Enter>",
                    submit_n = "<Enter>",
                },
                settings_window = {
                    border = {
                        style = "rounded",
                        text = {
                            top = " Settings ",
                        },
                    },
                    win_options = {
                        winhighlight = "Normal:Normal,FloatBorder:FloatBorder",
                    },
                },
                openai_params = {
                    model = "gpt-3.5-turbo",
                    frequency_penalty = 0,
                    presence_penalty = 0,
                    max_tokens = 300,
                    temperature = 0,
                    top_p = 1,
                    n = 1,
                },
                openai_edit_params = {
                    model = "code-davinci-edit-001",
                    temperature = 0,
                    top_p = 1,
                    n = 1,
                },
                actions_paths = { "~/dotfiles/lvim/chatgpt/actions.json" },
                show_quickfixes_cmd = "Trouble quickfix",
                predefined_chat_gpt_prompts = "https://raw.githubusercontent.com/f/awesome-chatgpt-prompts/main/prompts.csv",
            })
        end,
        dependencies = {
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim"
        }
    },
    { "morhetz/gruvbox" },
    { 'fatih/vim-go', build = ':GoUpdateBinaries' },
    {
        "phaazon/hop.nvim",
        branch = "v2",
        event = "BufRead",
        config = function()
            require("hop").setup()
            vim.api.nvim_set_keymap("n", "s", ":HopWord<cr>", { silent = true })
        end,
    },
    { "mfussenegger/nvim-dap" },
    {
        "leoluz/nvim-dap-go",
        config = function()
            require('dap-go').setup()
        end
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            require("dapui").setup()

            local dap, dapui = require("dap"), require("dapui")
            dap.listeners.after.event_initialized["dapui_config"] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated["dapui_config"] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited["dapui_config"] = function()
                dapui.close()
            end
        end,
    },
    {
        "theHamsta/nvim-dap-virtual-text",
        config = function()
            require("nvim-dap-virtual-text").setup()
        end
    },
    {
        "tpope/vim-fugitive",
        cmd = {
            "G",
            "Git",
            "Gdiffsplit",
            "Gread",
            "Gwrite",
            "Ggrep",
            "GMove",
            "GDelete",
            "GBrowse",
            "GRemove",
            "GRename",
            "Glgrep",
            "Gedit"
        },
        ft = { "fugitive" }
    },
    {
        "folke/trouble.nvim",
        cmd = "TroubleToggle",
    },
    { "rebelot/kanagawa.nvim" },
}

-- -- Autocommands (`:help autocmd`) <https://neovim.io/doc/user/autocmd.html>
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "zsh",
--   callback = function()
--     -- let treesitter use bash highlight for zsh files as well
--     require("nvim-treesitter.highlight").attach(0, "bash")
--   end,
-- })
