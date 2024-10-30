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
})

local function cmd(command)
    return table.concat({ '<Cmd>', command, '<CR>' })
end

-- 快捷键
local opts = { silent = true, noremap = true }
local function keymap(m, k, c)
    return vim.keymap.set(m, k, c, opts)
end

-- 跳-word
keymap("n", "s", cmd "HopWord")

keymap("n", ";", ":call VSCodeNotify('workbench.action.showCommands')<CR>")

keymap("n", "gi", ":call VSCodeNotify('editor.action.goToImplementation')<CR>")
keymap("n", "gr", ":call VSCodeNotify('editor.action.goToReferences')<CR>")
keymap("n", "gD", ":call VSCodeNotify('editor.action.goToTypeDefinition')<CR>")
keymap("n", "gd", ":call VSCodeNotify('editor.action.goToDeclaration')<CR>")
keymap("n", "<space>rn", ":call VSCodeNotify('editor.action.rename')<CR>")

