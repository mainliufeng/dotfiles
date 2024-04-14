local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end)

vim.keymap.set("n", "<S-U>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<S-I>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<S-O>", function() harpoon:list():select(3) end)
