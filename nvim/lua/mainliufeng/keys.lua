local function cmd(command)
    return table.concat({ '<Cmd>', command, '<CR>' })
end

-- 快捷键
local opts = { silent = true, noremap = true }
local function keymap(m, k, c)
    return vim.keymap.set(m, k, c, opts)
end

-- 跳
keymap("n", "s", cmd "HopWord")
keymap("n", "<C-j>", "<C-w>j")
keymap("n", "<C-k>", "<C-w>k")
keymap("n", "<C-h>", "<C-w>h")
keymap("n", "<C-l>", "<C-w>l")
keymap('n', '<C-w>z', cmd 'WinMaxToggle')
-- 搜
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
keymap("n", "<F3>", cmd "NvimTreeFindFileToggle")
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
    },
})
require "which-key".register({
    ["<space>"] = {
        t = { "<cmd>'<,'>ToggleTermSendVisualSelection<CR>", "Run visual selection" },
    },
}, { mode = "v" })
