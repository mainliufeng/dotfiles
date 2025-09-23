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
            scroll = { enabled = false },
            statuscolumn = { enabled = true },
            words = { enabled = true },
            terminal = {
                win = {
                    position = "float",
                    relative = "editor",
                    border = "rounded",
                    width = 0.9,
                    height = 0.9,
                },
            },
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
        event = "VimResized",  -- 只在窗口调整大小时加载
        config = function()
            require("bufresize").setup({
                register = {
                    keys = {},
                    trigger_events = { "BufWinEnter" },  -- 减少触发事件
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
        event = 'InsertEnter',  -- 只在进入插入模式时加载，减少初始化开销
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
                    auto_show_delay_ms = 500,  -- 增加延迟减少频繁更新
                },
            },
            signature = {
                enabled = true,
            },
            cmdline = {
                enabled = false,
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
            -- 读取并应用 .env（简化，无需 mtime 缓存），支持清理已删除变量
            local function read_env_file()
                local env_file = vim.fn.findfile('.env', '.;')
                if env_file == '' then
                    return nil, {}
                end

                local vars = {}
                local file = io.open(env_file, 'r')
                if file then
                    for line in file:lines() do
                        if not line:match('^%s*$') and not line:match('^%s*#') then
                            local key, value = line:match('^%s*([^=]+)%s*=%s*(.*)$')
                            if key and value then
                                value = value:gsub('^["\'](.*)["\']$', '%1')
                                vars[key] = value
                            end
                        end
                    end
                    file:close()
                end
                return env_file, vars
            end

            local last_env_keys = {}

            local function apply_env_from_dotenv()
                local _, vars = read_env_file()
                -- 清理上次设置但这次不存在的变量，避免脏值
                for key, _ in pairs(last_env_keys) do
                    if vars[key] == nil then
                        vim.env[key] = nil
                    end
                end
                -- 应用新变量
                for key, value in pairs(vars) do
                    vim.env[key] = value
                end
                last_env_keys = {}
                for key, _ in pairs(vars) do
                    last_env_keys[key] = true
                end
            end

            -- 启动时应用一次
            apply_env_from_dotenv()

            require("go").setup({
                test_runner = 'go',
                run_in_floaterm = false,
                floaterm = {
                    position = 'auto',
                    width = 0.45,
                    height = 0.98,
                },
            })

            -- .env 保存或删除时刷新环境变量
            vim.api.nvim_create_autocmd({"BufWritePost", "BufDelete"}, {
                pattern = {".env"},
                callback = function()
                    apply_env_from_dotenv()
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
            -- 设置交互式调试配置
            require('mainliufeng.config.go-debug').setup_quick_debug_presets()
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
