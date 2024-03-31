local mappings = {
    ["<2-LeftMouse>"] = "open",
    ["<cr>"] = "open",
    ["o"] = "open",
    ["<esc>"] = "cancel",
    ["S"] = "open_split",
    ["s"] = "open_vsplit",
    ["t"] = "open_tabnew",
    ["z"] = "close_all_nodes",
    ["a"] = {
        "add",
        config = {
            show_path = "none"
        }
    },
    ["A"] = "add_directory",
    ["d"] = "delete",
    ["r"] = "rename",
    ["y"] = "copy_to_clipboard",
    ["x"] = "cut_to_clipboard",
    ["p"] = "paste_from_clipboard",
    ["c"] = "copy",
    ["m"] = "move",
    ["q"] = "close_window",
    ["R"] = "refresh",
    ["?"] = "show_help",
    ["i"] = "show_file_details",
    ["oc"] = "",
    ["od"] = "",
    ["og"] = "",
    ["om"] = "",
    ["on"] = "",
    ["os"] = "",
    ["ot"] = "",
}
require("neo-tree").setup({
    window = {
        position = "current",
        mapping_options = {
            noremap = true,
            nowait = true,
        },
        mappings = mappings,
        filesystem = {
            window = {
                mappings = mappings,
            },
        },
    },
})
