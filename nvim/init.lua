-- Install plugins
require('plugins')

for i, file in pairs(vim.split(vim.fn.glob('~/.config/nvim/vim/*.vimrc'), '\n')) do
  vim.cmd('source ' .. file)
end

local paths = vim.split(vim.fn.glob('~/.config/nvim/vim/config/*.vimrc'), '\n')
for i, file in pairs(paths) do
  vim.cmd('source ' .. file)
end

require('config/nvim-tree')
require('config/cmp-nvim-lsp')
require('config.telescope')
require('config.exec')
require('config.lualine')
require('config.null-ls')
require('config.trouble')
require('config.hop')
require('config.toggleterm')
require('keys')
