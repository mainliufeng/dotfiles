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
    -----------------------------------------
    -- Basic
    -----------------------------------------
    -- lazy
    { "folke/lazy.nvim", tag = "stable" },
    -- treesitter
    { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate', event = "User FileOpened" },
    -- chatgpt
    {
        "mainliufeng/gpt",
        dir = "~/dotfiles/code/gpt",
        config = function()
            require("gpt").setup({
                current_session_file = vim.fn.stdpath("data"):gsub("/$", "") .. "/gpt/sessions/current.md",
                default_model = "gpt-4",
                default_temperature = 0.2,
                openai_url = "https://api.openai-proxy.org/v1/chat/completions",
                openai_api_key = os.getenv("OPENAI_API_KEY"),
            })
        end,
    },
    -- Search
    'nvim-lua/popup.nvim',
    'nvim-lua/plenary.nvim',
    {
        'nvim-telescope/telescope.nvim',
        tag = '0.1.5',
        dependencies = {
            "nvim-telescope/telescope-fzf-native.nvim",
            "nvim-lua/plenary.nvim",
        },
        config = function()
            require('mainliufeng.config.telescope')
        end
    },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make", lazy = true },
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
        'phaazon/hop.nvim',
        branch = 'v2',
        config = function()
            require 'hop'.setup { keys = 'etovxqpdygfblzhckisuran' }
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
    -- Keybinding
    'vim-scripts/LargeFile',
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
    -- File
    'kyazdani42/nvim-tree.lua',
    {
        'stevearc/oil.nvim',
        opts = {},
        -- Optional dependencies
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    -- Terminal
    {
        'akinsho/toggleterm.nvim',
        version = '*',
        config = function()
            require("toggleterm").setup()
        end
    },
    -- Which key
    "folke/which-key.nvim",

    -----------------------------------------
    -- Developer
    -----------------------------------------
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
    -- Python
    'klen/python-mode',
    -- Golang
    { 'fatih/vim-go', build = ':GoUpdateBinaries' },
    -- Jsonc (json which supports comment)
    { 'neoclide/jsonc.vim' },
    -- Lsp
    {
        "neovim/nvim-lspconfig",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
        },
        event = 'BufEnter',
        config = function()
            require('mainliufeng.config.lsp')
        end
    },
    {
        "ray-x/lsp_signature.nvim",
        config = function()
            require('lsp_signature').setup()
        end
    },
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
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "saadparwaiz1/cmp_luasnip",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            'hrsh7th/cmp-nvim-lua',
            'lukas-reineke/cmp-under-comparator',
            'hrsh7th/cmp-nvim-lsp-document-symbol',
        },
        event = 'InsertEnter *',
        config = function()
            require('mainliufeng.config.cmp')
        end
    },
    { "hrsh7th/cmp-nvim-lsp", lazy = true },
    { "saadparwaiz1/cmp_luasnip", lazy = true },
    { "hrsh7th/cmp-buffer", lazy = true },
    { "hrsh7th/cmp-path", lazy = true },
    { "hrsh7th/cmp-cmdline", lazy = true },
    {
        "L3MON4D3/LuaSnip",
        version = "v2",
        build = "make install_jsregexp",
        event = "InsertEnter",
        dependencies = { "friendly-snippets" },
        config = function()
            require("luasnip.loaders.from_lua").lazy_load()
            require("luasnip.loaders.from_vscode").lazy_load()
            require("luasnip.loaders.from_snipmate").lazy_load()
        end
    },
    { "molleweide/LuaSnip-snippets.nvim", lazy = true },
    { "rafamadriz/friendly-snippets", lazy = true },
    { "folke/neodev.nvim", opts = {} },
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
        dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
        config = function()
            require('mainliufeng.config.dap-ui')
        end
    },
    { "theHamsta/nvim-dap-virtual-text" },
    { "nvim-telescope/telescope-dap.nvim" },
    {
        "ThePrimeagen/harpoon",
        branch = "harpoon2",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require('mainliufeng.config.harpoon')
        end

    },
    { "nvim-telescope/telescope-project.nvim", dependencies = { "ThePrimeagen/harpoon" } },
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

require("mainliufeng.config.nvim-tree")

-- 本地插件
require("mainliufeng.plugins.git")
require("mainliufeng.plugins.window")
require("mainliufeng.plugins.highlight")

-- 通用配置
require("mainliufeng.keys")
