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

-- 跳到当前函数，上一个函数：[[
-- 跳到下一个函数：]]

-- 窗口
keymap("n", "<C-j>", "<C-w>j")
keymap("n", "<C-k>", "<C-w>k")
keymap("n", "<C-h>", "<C-w>h")
keymap("n", "<C-l>", "<C-w>l")
keymap('n', '<C-w>z', cmd 'WinMaxToggle')


keymap("n", "<C-f>", cmd "Telescope find_files hidden=true no_ignore=true")
keymap("n", "<C-b>", cmd "Telescope buffers initial_mode=insert")
keymap("n", ";", cmd "Telescope commands")

-- lsp
keymap("n", "gh", "<cmd>Lspsaga lsp_finder<CR>")
keymap("n", "gd", "<cmd>lua require('telescope.builtin').lsp_definitions()<CR>")
keymap("n", "gD", "<cmd>lua require('telescope.builtin').lsp_type_definitions()<CR>")
keymap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
keymap("n", "gr", "<cmd>lua require('telescope.builtin').lsp_references()<CR>")
keymap("n", "gi", "<cmd>lua require('telescope.builtin').lsp_implementations()<CR>")
keymap("n", "gI", "<cmd>lua require('telescope.builtin').lsp_incoming_calls()<CR>")
keymap("n", "gO", "<cmd>lua require('telescope.builtin').lsp_outgoing_calls()<CR>")
keymap("n", "<C-p>", "<cmd>lua require('telescope.builtin').lsp_document_symbols()<CR>")
keymap("n", "<C-s>", "<cmd>lua require('telescope.builtin').lsp_dynamic_workspace_symbols()<CR>")
keymap({ "n", "v" }, "ga", "<cmd>Lspsaga code_action<CR>")
keymap("n", "<space>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")

-- terminal
keymap("n", "<C-\\>", cmd 'exe v:count1 . "ToggleTerm direction=float"')
keymap("i", "<C-\\>", '<Esc><Cmd>exe v:count1 . "ToggleTerm direction=float"<CR>')
keymap("n", "<leader>x", "<cmd>:read !sh %<cr>")

-- debug
keymap("n", "<F3>", cmd "Neotree reveal=true position=left toggle")
keymap("n", "<C-e>", cmd "Neotree reveal=true toggle")
keymap("n", "<F4>", cmd "lua require'dapui'.toggle()")
keymap("n", "<F5>", cmd "lua require'dap'.continue()")
keymap("n", "<F10>", cmd "lua require'dap'.step_over()")
keymap("n", "<F11>", cmd "lua require'dap'.step_into()")
keymap("n", "<F12>", cmd "lua require'dap'.step_out()")

require "which-key".register({
    ["<space>"] = {
        p = { "<cmd>Telescope project<CR>", "Projects" },
        g = { "<cmd>Telescope live_grep<cr>", "Live grep" },
        b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
        e = { function()
            local harpoon = require("harpoon")
            harpoon.ui:toggle_quick_menu(harpoon:list())
        end, "Harpoon" },
    },
})
require "which-key".register({
    ["<space>"] = {
        t = { "<cmd>'<,'>ToggleTermSendVisualSelection<CR>", "Run visual selection" },
    },
}, { mode = "v" })

-- Windsurf (Codeium) AI 快捷键
require "which-key".register({
    ["<space>"] = {
        a = {
            name = "AI Assistant",
            c = { "<cmd>Codeium Chat<cr>", "Open Codeium Chat" },
            t = { "<cmd>Codeium Toggle<cr>", "Toggle Codeium" },
            s = { function() 
                local status = require('codeium.virtual_text').status_string()
                print("Codeium Status: " .. status)
            end, "Show Codeium Status" },
        },
    },
})

-- Windsurf AI 补全快捷键 (使用 Alt 组合避免冲突)
-- Alt+Enter: 接受 AI 建议
keymap("i", "<M-CR>", function()
    return require('codeium.virtual_text').accept()
end)
-- Alt+]: 下一个 AI 建议  
keymap("i", "<M-]>", function()
    return require('codeium.virtual_text').cycle_or_complete(1)
end)
-- Alt+[: 上一个 AI 建议
keymap("i", "<M-[>", function()
    return require('codeium.virtual_text').cycle_or_complete(-1)
end)
-- Alt+x: 清除 AI 建议
keymap("i", "<M-x>", function()
    return require('codeium.virtual_text').clear()
end)
