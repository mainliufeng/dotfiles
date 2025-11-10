local function cmd(command)
    return table.concat({ '<Cmd>', command, '<CR>' })
end

-- 快捷键
local opts = { silent = true, noremap = true }
local function keymap(m, k, c)
    return vim.keymap.set(m, k, c, opts)
end

local terminal = require("mainliufeng.config.terminal")

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
keymap("n", "<C-\\>", function()
    terminal.toggle(vim.v.count1)
end)
keymap("i", "<C-\\>", function()
    local count = vim.v.count1
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
    vim.schedule(function()
        terminal.toggle(count)
    end)
end)
keymap("n", "<leader>x", "<cmd>:read !sh %<cr>")

-- debug
keymap("n", "<F3>", cmd "Neotree reveal=true position=left toggle")
keymap("n", "<C-e>", cmd "Neotree reveal=true toggle")
keymap("n", "<F4>", cmd "lua require'dapui'.toggle()")
keymap("n", "<F5>", cmd "lua require'dap'.continue()")
keymap("n", "<F6>", cmd "lua require'mainliufeng.config.go-debug'.setup_debug_with_ui()")
keymap("n", "<F10>", cmd "lua require'dap'.step_over()")
keymap("n", "<F11>", cmd "lua require'dap'.step_into()")
keymap("n", "<F12>", cmd "lua require'dap'.step_out()")

require "which-key".add({
    { "<space>p", "<cmd>Telescope project<CR>", desc = "Projects" },
    { "<space>g", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
    { "<space>b", "<cmd>Telescope git_branches<cr>", desc = "Checkout branch" },
    { "<space>e", function()
        local harpoon = require("harpoon")
        harpoon.ui:toggle_quick_menu(harpoon:list())
    end, desc = "Harpoon" },
})
require "which-key".add({
    {
        "<space>t",
        function()
            terminal.send_visual(vim.v.count1)
        end,
        desc = "Run visual selection",
        mode = "v",
    },
})

-- Debug 相关快捷键
require "which-key".add({
    { "<space>d", group = "Debug" },
    { "<space>dc", "<cmd>lua require'dap'.continue()<cr>", desc = "Continue" },
    { "<space>du", "<cmd>lua require'dapui'.toggle()<cr>", desc = "Toggle UI" },
    { "<space>di", "<cmd>lua require'mainliufeng.config.go-debug'.setup_debug_with_ui()<cr>", desc = "Interactive Debug" },
    { "<space>db", "<cmd>lua require'dap'.toggle_breakpoint()<cr>", desc = "Toggle Breakpoint" },
    { "<space>dB", "<cmd>lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))<cr>", desc = "Conditional Breakpoint" },
    { "<space>ds", "<cmd>Telescope dap configurations<cr>", desc = "Debug Configurations" },
    { "<space>dr", "<cmd>lua require'dap'.run_last()<cr>", desc = "Run Last" },
    { "<space>dt", "<cmd>lua require'dap'.terminate()<cr>", desc = "Terminate" },
})
