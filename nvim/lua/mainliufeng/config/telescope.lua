local actions = require('telescope.actions')
local trouble = require("trouble.providers.telescope")
local project_actions = require("telescope._extensions.project.actions")
-- Global remapping
------------------------------
require('telescope').setup {
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
    },
    extensions = {
        project = {
            base_dirs = {
                { path = '~/Code/rcrai', max_depth = 2 },
                { path = '~/Code/self', max_depth = 2 },
                { path = '~/Code/source', max_depth = 2 },
                '~/dotfiles',
                '~/dotfiles-private',
            },
            ignore_missing_dirs = true,
            hidden_files = true, -- default: false
            theme = "dropdown",
            order_by = "asc",
            search_by = { "title", "path" },
            sync_with_nvim_tree = true, -- default false
            -- default for on_project_selected = find project files
            on_project_selected = function(prompt_bufnr)
                project_actions.change_working_directory(prompt_bufnr, false)
                local harpoon = require("harpoon")
                if harpoon:list():length() > 0 then
                    harpoon:list():select(1)
                end
            end
        }
    }
}
require('telescope').load_extension('project')
require('telescope').load_extension('dap')
