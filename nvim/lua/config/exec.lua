vim.api.nvim_set_keymap("n", "<leader>x", "<cmd>:term sh %<cr>",
  {silent = true, noremap = true}
)
vim.api.nvim_set_keymap("n", "<leader>l", "<cmd>:.w !sh<cr>",
  {silent = true, noremap = true}
)
