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
