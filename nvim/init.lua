-- Install plugins
require('plugins')
require('funcs')

for i, file in pairs(vim.split(vim.fn.glob('~/.config/nvim/vim/*.vimrc'), '\n')) do
    vim.cmd('source ' .. file)
end

local paths = vim.split(vim.fn.glob('~/.config/nvim/vim/config/*.vimrc'), '\n')
for i, file in pairs(paths) do
    vim.cmd('source ' .. file)
end
require('keys')
