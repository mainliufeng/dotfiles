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
        "jackMort/ChatGPT.nvim",
        event = "VeryLazy",
        config = function()
            require("config.chatgpt")
        end,
        dependencies = {
            "MunifTanjim/nui.nvim",
            "nvim-lua/plenary.nvim",
            "nvim-telescope/telescope.nvim"
        }
    },
    -- Search
    'nvim-lua/popup.nvim',
    'nvim-lua/plenary.nvim',
    {
        'nvim-telescope/telescope.nvim',
        dependencies = { "nvim-telescope/telescope-fzf-native.nvim" },
        lazy = true,
        config = function()
            require('config.telescope')
        end
    },
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make", lazy = true },
    -- Line
    {
        'nvim-lualine/lualine.nvim',
        config = function()
            require('config.lualine')
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
    -- Tree
    'kyazdani42/nvim-tree.lua',
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
            require('config.lsp')
        end
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
            require('config.cmp')
        end
    },
    { "hrsh7th/cmp-nvim-lsp", lazy = true },
    { "saadparwaiz1/cmp_luasnip", lazy = true },
    { "hrsh7th/cmp-buffer", lazy = true },
    { "hrsh7th/cmp-path", lazy = true },
    { "hrsh7th/cmp-cmdline", lazy = true },
    {
        "L3MON4D3/LuaSnip",
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
    { "folke/neodev.nvim", lazy = true },
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
    { "leoluz/nvim-dap-go" },
    {
        "rcarriga/nvim-dap-ui",
        dependencies = { "mfussenegger/nvim-dap" },
        config = function()
            require('config.dap-ui')
        end
    },
    { "theHamsta/nvim-dap-virtual-text" },
    { "nvim-telescope/telescope-dap.nvim" },
    { "ThePrimeagen/harpoon" },
    { "nvim-telescope/telescope-project.nvim", dependencies = { "ThePrimeagen/harpoon" } },
    -- Error
    { 'jose-elias-alvarez/null-ls.nvim' },
    {
        "folke/trouble.nvim",
        dependencies = "kyazdani42/nvim-web-devicons",
        config = function()
            require('config.trouble')
        end
    },
})

require("config.nvim-tree")
