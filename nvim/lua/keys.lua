local function cmd(command)
    return table.concat({ '<Cmd>', command, '<CR>' })
end

-- 快捷键
vim.api.nvim_set_keymap("n", "<C-\\>", cmd 'exe v:count1 . "ToggleTerm direction=float"',
    { silent = true, noremap = true })
vim.api.nvim_set_keymap("i", "<C-\\>", '<Esc><Cmd>exe v:count1 . "ToggleTerm direction=float"<CR>',
    { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<C-j>", "<C-w>j", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<C-k>", "<C-w>k", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<C-h>", "<C-w>h", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<C-l>", "<C-w>l", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<C-c>", cmd "ChatGPT", { silent = true, noremap = true })
vim.api.nvim_set_keymap("v", "<C-e>", cmd "lua require'chatgpt'.edit_with_instructions()",
    { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "s", cmd "HopWord", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<C-f>", cmd "Telescope find_files hidden=true no_ignore=true",
    { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<C-b>", cmd "Telescope buffers initial_mode=insert", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<C-p>", cmd "lua require('telescope.builtin').lsp_document_symbols()",
    { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<C-s>", cmd "lua require('telescope.builtin').lsp_dynamic_workspace_symbols()",
    { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", ";", cmd "Telescope commands", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<F3>", cmd "NvimTreeFindFileToggle", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<F4>", cmd "lua require'dapui'.toggle()", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<F5>", cmd "lua require'dap'.continue()", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<F10>", cmd "lua require'dap'.step_over()", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<F11>", cmd "lua require'dap'.step_into()", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<F12>", cmd "lua require'dap'.step_out()", { silent = true, noremap = true })
vim.api.nvim_set_keymap("n", "<leader>x", "<cmd>:term sh %<cr>",
    { silent = true, noremap = true }
)
vim.api.nvim_set_keymap("n", "<leader>l", "<cmd>:.w !sh<cr>",
    { silent = true, noremap = true }
)

require "which-key".register({
    ["<space>"] = {
        p = { "<cmd>Telescope project<CR>", "Projects" },
        f = { "<cmd>Telescope find_files hidden=true no_ignore=true<cr>", "Finds" },
        g = { "<cmd>Telescope live_grep<cr>", "Live grep" },
        b = { "<cmd>Telescope git_branches<cr>", "Checkout branch" },
    },
})
require "which-key".register({
    ["<space>"] = {
        t = { "<cmd>'<,'>ToggleTermSendVisualSelection<CR>", "Run visual selection" },
    },
}, { mode = "v" })

-- vim.keymap.set({ "n", "x" }, "<leader>ssr", cmd 'lua require(\'ssr\').open()')
-- -- telescope
-- vim.api.nvim_set_keymap("n", "T", cmd 'Telescope', { silent = true, noremap = true })
-- vim.api.nvim_set_keymap("n", "<C-f>", cmd 'Telescope find_files', { silent = true, noremap = true })
-- vim.api.nvim_set_keymap("n", "<C-p>", cmd 'lua require(\'telescope.builtin\').lsp_document_symbols()',
--     { silent = true, noremap = true })
-- vim.api.nvim_set_keymap("n", "<C-s>", cmd 'lua require(\'telescope.builtin\').lsp_dynamic_workspace_symbols()',
--     { silent = true, noremap = true })
-- vim.api.nvim_set_keymap("n", ";", cmd 'Telescope commands', { silent = true, noremap = true })
-- -- telescope <leader>t
-- vim.api.nvim_set_keymap("n", '<leader>tb', cmd 'lua require(\'telescope.builtin\').buffers()', {
--     silent = true, noremap = true, desc = 'Buffers'
-- })
-- vim.api.nvim_set_keymap("n", '<leader>tp', cmd 'lua require(\'telescope.builtin\').lsp_document_symbols()', {
--     silent = true, noremap = true, desc = 'File symbols'
-- })
-- vim.api.nvim_set_keymap("n", '<leader>ts', cmd 'lua require(\'telescope.builtin\').lsp_dynamic_workspace_symbols()', {
--     silent = true, noremap = true, desc = 'Project symbols'
-- })
-- vim.api.nvim_set_keymap("n", '<leader>tf', cmd 'Telescope find_files', {
--     silent = true, noremap = true, desc = 'Files'
-- })
-- vim.api.nvim_set_keymap("n", '<leader>tg', cmd 'Telescope live_grep', {
--     silent = true, noremap = true, desc = 'Live grep'
-- })
-- vim.api.nvim_set_keymap("n", '<leader>th', cmd 'Telescope help_tags', {
--     silent = true, noremap = true, desc = 'Vim help'
-- })
-- vim.api.nvim_set_keymap("n", '<leader>to', cmd 'Telescope oldfiles', {
--     silent = true, noremap = true, desc = 'Recently opened files'
-- })
-- vim.api.nvim_set_keymap("n", '<leader>tm', cmd 'MarksListBuf', {
--     silent = true, noremap = true, desc = 'Marks'
-- })
-- vim.api.nvim_set_keymap("n", '<leader>tk', cmd 'Telescope keymaps', {
--     silent = true, noremap = true, desc = 'Keymaps'
-- })
-- vim.api.nvim_set_keymap("n", '<leader>tr', cmd 'Telescope registers', {
--     silent = true, noremap = true, desc = 'Registers'
-- })
-- vim.api.nvim_set_keymap("n", '<leader>t/', cmd 'Telescope current_buffer_fuzzy_find', {
--     silent = true, noremap = true, desc = 'Search in file'
-- })
-- vim.api.nvim_set_keymap("n", '<leader>t?', cmd 'Telescope search_history', {
--     silent = true, noremap = true, desc = 'Search history'
-- })
-- vim.api.nvim_set_keymap("n", '<leader>t;', cmd 'Telescope command_history', {
--     silent = true, noremap = true, desc = 'Command-line history'
-- })
-- vim.api.nvim_set_keymap("n", '<leader>tc', cmd 'Telescope commands', {
--     silent = true, noremap = true, desc = 'Execute command'
-- })
--
-- -- dap
-- vim.api.nvim_set_keymap("n", "<F4>", cmd "lua require'dapui'.toggle()", { silent = true, noremap = true })
-- vim.api.nvim_set_keymap("n", "<F5>", cmd "lua require'dap'.continue()", { silent = true, noremap = true })
-- vim.api.nvim_set_keymap("n", "<F10>", cmd "lua require'dap'.step_over()", { silent = true, noremap = true })
-- vim.api.nvim_set_keymap("n", "<F11>", cmd "lua require'dap'.step_into()", { silent = true, noremap = true })
-- vim.api.nvim_set_keymap("n", "<F12>", cmd "lua require'dap'.step_out()", { silent = true, noremap = true })
-- vim.api.nvim_set_keymap("n", "<leader>b", cmd "lua require'dap'.toggle_breakpoint()", { silent = true, noremap = true })
-- vim.api.nvim_set_keymap("n", "<leader>B", cmd "lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: '))",
--     { silent = true, noremap = true })
-- vim.api.nvim_set_keymap("n", "<leader>lp",
--     cmd "lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))",
--     { silent = true, noremap = true })
-- vim.api.nvim_set_keymap("n", "<leader>dr", cmd "lua require'dap'.repl.open()", { silent = true, noremap = true })
-- vim.api.nvim_set_keymap("n", "<leader>dl", cmd "lua require'dap'.run_last()", { silent = true, noremap = true })
-- -- git-fugitive
-- vim.api.nvim_set_keymap("n", "<leader>gs", ":G<CR>", { silent = true, noremap = true })
-- vim.api.nvim_set_keymap("n", "<leader>gh", ":diffget //2<CR>", { silent = true, noremap = true })
-- vim.api.nvim_set_keymap("n", "<leader>gl", ":diffget //3<CR>", { silent = true, noremap = true })
-- -- source vimrc
-- vim.api.nvim_set_keymap("n", "<leader>src", ":source $MYVIMRC<cr>",
--     { silent = true, noremap = true, desc = 'Source vimrc' })
