local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable", -- latest stable release
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- set leader
vim.g.mapleader = ','
vim.api.nvim_set_var("localleader", ',')

require("lazy").setup({
    {
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        ---@type snacks.Config
        opts = {
            -- your configuration comes here
            -- or leave it empty to use the default settings
            -- refer to the configuration section below
            bigfile = { enabled = true },
            dashboard = { enabled = true },
            explorer = { enabled = true },
            indent = { enabled = true },
            input = { enabled = true },
            picker = { enabled = true },
            notifier = {
                enabled = true,
                timeout = 3000,
            },
            quickfile = { enabled = true },
            scope = { enabled = true },
            scroll = { enabled = true },
            statuscolumn = { enabled = true },
            words = { enabled = true },
        },
    },
    -----------------------------------------
    -- Basic
    -----------------------------------------
    -- lazy
    { "folke/lazy.nvim",       tag = "stable" },
    -- Which key
    "folke/which-key.nvim",
    -- mark
    --{
    --    "robitx/gp.nvim",
    --    dir = "~/dotfiles/code/gp.nvim",
    --    config = function()
    --        require('mainliufeng.config.gp')
    --    end,
    --},
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require('mainliufeng.config.harpoon')
        end

    },
    -- Search
    'nvim-lua/popup.nvim',
    'nvim-lua/plenary.nvim',
    {
        'nvim-telescope/telescope.nvim',
        branch = '0.1.x',
        dependencies = {
            { "nvim-lua/plenary.nvim" },
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make",                           lazy = true },
            { "nvim-telescope/telescope-project.nvim",    dependencies = { "ThePrimeagen/harpoon" } },
        },
        config = function()
            require('mainliufeng.config.telescope')
        end
    },
    { 'stevearc/dressing.nvim' },
    -- Line
    {
        'nvim-lualine/lualine.nvim',
        config = function()
            require('mainliufeng.config.lualine')
        end
    },
    -- Theme
    'morhetz/gruvbox',
    -- Undo Tree
    'mbbill/undotree',
    -- Jump
    {
        'smoka7/hop.nvim',
        version = '*',
        opt = {},
        config = function()
            require("hop").setup({ keys = 'etovxqpdygfblzhckisuran' })
        end
    },
    {
        "kwkarlwang/bufresize.nvim",
        config = function()
            require("bufresize").setup({
                register = {
                    keys = {},
                    trigger_events = { "BufWinEnter", "WinEnter" },
                },
                resize = {
                    keys = {},
                    trigger_events = { "VimResized" },
                    increment = 5,
                },
            })
        end,
    },
    -- LargeFile
    --'vim-scripts/LargeFile',
    -- Git
    'airblade/vim-gitgutter',
    {
        'tpope/vim-fugitive',
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
        ft = { "fugitive" },
    },
    -- File tree
    {
        "nvim-neo-tree/neo-tree.nvim",
        branch = "v3.x",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
            "MunifTanjim/nui.nvim",
        },
        config = function()
            require("mainliufeng.config.neotree")
        end

    },
    -- Terminal
    {
        'akinsho/toggleterm.nvim',
        version = '*',
        config = function()
            require("toggleterm").setup()
        end
    },

    -- Treesitter
    { 'nvim-treesitter/nvim-treesitter', tag = "v0.9.2",             build = ':TSUpdate', event = "User FileOpened" },
    {
        "ThePrimeagen/refactoring.nvim",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("refactoring").setup()
        end,
    },
    {
        "glepnir/lspsaga.nvim",
        event = "LspAttach",
        config = function()
            require("mainliufeng.config.lspsaga")
        end,
        dependencies = {
            { "nvim-tree/nvim-web-devicons" },
            --Please make sure you install markdown and markdown_inline parser
            { "nvim-treesitter/nvim-treesitter" }
        }
    },

    -- AI Code Completion
    {
        'Exafunction/windsurf.vim',
        event = 'BufEnter',
        config = function()
            require('mainliufeng.config.windsurf')
        end
    },
    -- Completion
    {
        'saghen/blink.cmp',
        lazy = false,
        dependencies = 'rafamadriz/friendly-snippets',
        version = 'v0.*',
        opts = {
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
            },
            completion = {
                accept = {
                    auto_brackets = {
                        enabled = true,
                    },
                },
                menu = {
                    draw = {
                        treesitter = { 'lsp' }
                    }
                },
                documentation = {
                    auto_show = true,
                    auto_show_delay_ms = 200,
                },
            },
        },
        opts_extend = { "sources.default" }
    },
    -- Lsp
    {
        "neovim/nvim-lspconfig",
        lazy = false,
        config = function()
            require('mainliufeng.config.lsp')
        end,
    },
    --{
    --    'hrsh7th/nvim-cmp',
    --    dependencies = {
    --        -- lsp
    --        { "neovim/nvim-lspconfig" },
    --        { "ray-x/lsp_signature.nvim" },
    --        -- complete
    --        { "hrsh7th/cmp-nvim-lsp" },
    --        { "saadparwaiz1/cmp_luasnip" },
    --        { "hrsh7th/cmp-buffer" },
    --        { "hrsh7th/cmp-path" },
    --        { "hrsh7th/cmp-cmdline" },
    --        { 'hrsh7th/cmp-nvim-lua' },
    --        { 'lukas-reineke/cmp-under-comparator' },
    --        { 'hrsh7th/cmp-nvim-lsp-document-symbol' },
    --        -- snippet
    --        { "L3MON4D3/LuaSnip", version = "v2", build = "make install_jsregexp" },
    --        { "molleweide/LuaSnip-snippets.nvim" },
    --        { "rafamadriz/friendly-snippets" },
    --        { "folke/neodev.nvim" },
    --    },
    --    event = 'BufEnter',
    --    config = function()
    --        require('mainliufeng.config.cmp')
    --        require('mainliufeng.config.lsp')
    --        require('lsp_signature').setup()
    --        --require("luasnip.loaders.from_lua").lazy_load()
    --        --require("luasnip.loaders.from_vscode").lazy_load()
    --        --require("luasnip.loaders.from_snipmate").lazy_load()
    --    end
    --},

    -- Developer
    { 'fatih/vim-go',                    build = ':GoUpdateBinaries' },
    {
        "ray-x/go.nvim",
        dependencies = {
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            -- Function to load .env file
            local function load_env_file()
                local env_file = vim.fn.findfile('.env', '.;')
                if env_file == '' then
                    return {}
                end
                
                local env_vars = {}
                local file = io.open(env_file, 'r')
                if file then
                    for line in file:lines() do
                        -- Skip empty lines and comments
                        if not line:match('^%s*$') and not line:match('^%s*#') then
                            local key, value = line:match('^([^=]+)=(.*)$')
                            if key and value then
                                -- Remove quotes if present
                                value = value:gsub('^["\'](.*)["\']$', '%1')
                                env_vars[key] = value
                            end
                        end
                    end
                    file:close()
                end
                return env_vars
            end
            
            -- Load environment variables and set them
            local env_vars = load_env_file()
            for key, value in pairs(env_vars) do
                vim.fn.setenv(key, value)
            end
            
            require("go").setup({
                -- Enable environment variable loading for tests
                test_runner = 'go', -- can be go, ginkgo, richgo, dlv, ginkgo
                run_in_floaterm = false, -- set to true to run in float window
                floaterm = {   -- position of float window
                    posititon = 'auto', -- one of {`top`, `bottom`, `left`, `right`, `center`, `auto`}
                    width = 0.45, -- width of float window if not auto
                    height = 0.98, -- height of float window if not auto
                },
            })
            
            -- Reload env vars on buffer enter
            vim.api.nvim_create_autocmd({"BufEnter"}, {
                pattern = {"*.go"},
                callback = function()
                    local env_vars = load_env_file()
                    for key, value in pairs(env_vars) do
                        vim.fn.setenv(key, value)
                    end
                end
            })
        end,
        event = { "CmdlineEnter" },
        ft = { "go", 'gomod' },
        build = ':lua require("go.install").update_all_sync()' -- if you need to install/update all binaries
    },
    { 'neoclide/jsonc.vim' },
    {
        "hedyhli/outline.nvim",
        lazy = true,
        cmd = { "Outline", "OutlineOpen" },
        keys = {
            { "go", "<cmd>Outline<CR>", desc = "Toggle outline" },
        },
        opts = {
        },
    },
    {
        "cshuaimin/ssr.nvim",
        -- Calling setup is optional.
        config = function()
            require("ssr").setup {
                min_width = 50,
                min_height = 5,
                keymaps = {
                    close = "q",
                    next_match = "n",
                    prev_match = "N",
                    replace_all = "<leader><cr>",
                },
            }
        end
    },
    -- Debug
    { "mfussenegger/nvim-dap" },
    {
        "leoluz/nvim-dap-go",
        config = function()
            require('dap-go').setup()
        end
    },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio",
        },
        config = function()
            require('mainliufeng.config.dap-ui')
        end
    },
    { "theHamsta/nvim-dap-virtual-text" },
    { "nvim-telescope/telescope-dap.nvim" },
    -- Error
    { 'jose-elias-alvarez/null-ls.nvim' },
    {
        "folke/trouble.nvim",
        dependencies = "nvim-tree/nvim-web-devicons",
        config = function()
            require('mainliufeng.config.trouble')
        end
    },
})

-- 本地插件
require("mainliufeng.plugins.git")
require("mainliufeng.plugins.window")
require("mainliufeng.plugins.highlight")

-- 通用配置
require("mainliufeng.keys")
