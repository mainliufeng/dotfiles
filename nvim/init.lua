if vim.g.vscode then
    -- Install plugins
    require('mainliufengvscode')
else
    -- Install plugins
    require('mainliufeng')

    for _, file in pairs(vim.split(vim.fn.glob('~/.config/nvim/vim/*.vimrc'), '\n')) do
        vim.cmd('source ' .. file)
    end

    local paths = vim.split(vim.fn.glob('~/.config/nvim/vim/config/*.vimrc'), '\n')
    for _, file in pairs(paths) do
        vim.cmd('source ' .. file)
    end
end
