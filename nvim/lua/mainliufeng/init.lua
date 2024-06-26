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
    -- Which key
    "folke/which-key.nvim",
    -- chatgpt
    --{
    --    "mainliufeng/gpt",
    --    dir = "~/dotfiles/code/gpt",
    --    config = function()
    --        require("gpt").setup({
    --            current_session_file = vim.fn.stdpath("data"):gsub("/$", "") .. "/gpt/sessions/current.md",
    --            default_temperature = 0.2,
    --            -- gpt4 turbo
    --            default_model = "gpt-4-0125-preview",
    --            openai_url = "https://api.openai-proxy.org/v1/chat/completions",
    --            openai_api_key = os.getenv("OPENAI_API_KEY"),

    --            -- 千循
    --            -- default_model = "qianxun-l-128k",
    --            -- openai_url = "https://qianxun-dev.rcrai.com/open/v1/chat/completions",
    --            -- openai_api_key = "ckm-248338a4ef7a0c728cce2624db60f3d4",
    --        })
    --    end,
    --},
    -- mark
    {
        "robitx/gp.nvim",
        dir = "~/dotfiles/code/gp.nvim",
        config = function()
            require('mainliufeng.config.gp')
        end,
    },
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
            { "nvim-telescope/telescope-fzf-native.nvim", build = "make", lazy = true },
            { "nvim-telescope/telescope-project.nvim", dependencies = { "ThePrimeagen/harpoon" } },
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
    { 'nvim-treesitter/nvim-treesitter', tag = "v0.9.2", build = ':TSUpdate', event = "User FileOpened" },
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

    -- Lsp 
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            -- lsp
            { "neovim/nvim-lspconfig" },
            { "ray-x/lsp_signature.nvim" },
            -- complete
            { "hrsh7th/cmp-nvim-lsp" },
            { "saadparwaiz1/cmp_luasnip" },
            { "hrsh7th/cmp-buffer" },
            { "hrsh7th/cmp-path" },
            { "hrsh7th/cmp-cmdline" },
            { 'hrsh7th/cmp-nvim-lua' },
            { 'lukas-reineke/cmp-under-comparator' },
            { 'hrsh7th/cmp-nvim-lsp-document-symbol' },
            -- snippet
            { "L3MON4D3/LuaSnip", version = "v2", build = "make install_jsregexp" },
            { "molleweide/LuaSnip-snippets.nvim" },
            { "rafamadriz/friendly-snippets" },
            { "folke/neodev.nvim" },
        },
        event = 'BufEnter',
        config = function()
            require('mainliufeng.config.cmp')
            require('mainliufeng.config.lsp')
            require('lsp_signature').setup()
            require("luasnip.loaders.from_lua").lazy_load()
            require("luasnip.loaders.from_vscode").lazy_load()
            require("luasnip.loaders.from_snipmate").lazy_load()
        end
    },

    -- Developer
    { 'fatih/vim-go', build = ':GoUpdateBinaries' },
    {
        "ray-x/go.nvim",
        dependencies = {
            "ray-x/guihua.lua",
            "neovim/nvim-lspconfig",
            "nvim-treesitter/nvim-treesitter",
        },
        config = function()
            require("go").setup()
        end,
        event = {"CmdlineEnter"},
        ft = {"go", 'gomod'},
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
