local actions = require('telescope.actions')
local trouble = require("trouble.providers.telescope")
-- Global remapping
------------------------------
require('telescope').setup{
  defaults = {
    sorting_strategy = 'ascending',
    layout_strategy = 'vertical',
    layout_config = {
      width = 0.95,
      vertical = {
        mirror = true,
      },
    },
    mappings = {
      i = {
        ["<C-n>"] = false,
        ["<C-p>"] = false,
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-v>"] = false,
        -- ["<c-t>"] = trouble.open_with_trouble,
      },
      n = {
        -- ["<c-t>"] = trouble.open_with_trouble
      },
    },
  }
}
require('telescope').load_extension('dap')
require('telescope').load_extension('project')
