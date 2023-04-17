require('telescope').load_extension('dap')

vim.api.nvim_set_keymap("n", "<leader>d", "<cmd>:Telescope dap commands<cr>",
  {silent = true, noremap = true}
)
