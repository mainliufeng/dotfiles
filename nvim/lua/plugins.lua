local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
  packer_bootstrap = fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

vim.cmd('packadd packer.nvim')

-- the plugin install follows from here
return require('packer').startup(function(use)
  -- Packer can manage itself
  use 'wbthomason/packer.nvim'

  -----------------------------------------
  -- Basic
  -----------------------------------------
  use 'kyazdani42/nvim-web-devicons' -- for file icons
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  use {
    "cshuaimin/ssr.nvim",
    module = "ssr",
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
  }
  -- Search
  use 'nvim-lua/popup.nvim'
  use 'nvim-lua/plenary.nvim'
  use 'nvim-telescope/telescope.nvim'
  -- Line
  use 'nvim-lualine/lualine.nvim'
  -- Theme
  use 'morhetz/gruvbox'
  -- Undo Tree
  use 'mbbill/undotree'
  -- Jump
  use { 'phaazon/hop.nvim', branch = 'v2' }
  -- Keybinding
  use { 'anuvyklack/hydra.nvim', requires = 'anuvyklack/keymap-layer.nvim' }
  use 'vim-scripts/LargeFile'
  -- Git
  use 'airblade/vim-gitgutter'
  use 'tpope/vim-fugitive'
  -- Tree
  use 'kyazdani42/nvim-tree.lua'
  -- Terminal
  use { 'akinsho/toggleterm.nvim', tag = '*' }
  -- Which key
  use {
    "folke/which-key.nvim",
    config = [[ require('config.which-key') ]],
  }
  -----------------------------------------

  -- Python
  use 'klen/python-mode'
  -- Golang
  use { 'fatih/vim-go', run = ':GoUpdateBinaries' }
  -- Jsonc (json which supports comment)
  use { 'neoclide/jsonc.vim' }

  -- Lsp
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      { 'hrsh7th/cmp-nvim-lsp', 
        requires = { 'neovim/nvim-lspconfig' } },
      { 'L3MON4D3/LuaSnip',
        requires = {
          "rafamadriz/friendly-snippets",
          "molleweide/LuaSnip-snippets.nvim",
        },
      },
      { 'hrsh7th/cmp-nvim-lua', after = 'nvim-cmp' },
      { 'saadparwaiz1/cmp_luasnip', after = 'nvim-cmp' },
      { 'lukas-reineke/cmp-under-comparator', after = 'nvim-cmp' },
      { 'hrsh7th/cmp-nvim-lsp-document-symbol', after = 'nvim-cmp' },
    },
    config = [[ require('config.cmp') ]],
    event = 'InsertEnter *',
  }

  -- Debug
  use { "mfussenegger/nvim-dap" }
  use {
    "leoluz/nvim-dap-go",
    config = function()
      require('dap-go').setup()
    end
  }
  use { 
    "rcarriga/nvim-dap-ui", 
    requires = {"mfussenegger/nvim-dap"}, 
    config = [[ require('config.dap-ui') ]],
  }
  use { 
    "theHamsta/nvim-dap-virtual-text", 
    config = function()
      require("nvim-dap-virtual-text").setup()
    end
  }
  use { 
    "nvim-telescope/telescope-dap.nvim", 
    config = [[ require('config.telescope-dap') ]],
  }
  use { 
    "nvim-telescope/telescope-project.nvim",
    config = [[ require('config.telescope-project') ]],
  }

  -- Error
  use 'jose-elias-alvarez/null-ls.nvim'
  use { "folke/trouble.nvim", requires = "kyazdani42/nvim-web-devicons" }

end)
