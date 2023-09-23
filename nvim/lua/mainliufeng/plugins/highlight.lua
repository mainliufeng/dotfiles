local config = {
    colors = {
        '#1899d3',
        '#8a8ff8',
        '#dec63d',
        '#549bce',
        '#c6b7a4',
        '#efcad6',
        '#658080',
        '#70c5ca',
        '#8ca231',
        '#ba2320',
    },
}

local function color_to_highlight_group(color)
    if string.sub(color, 1, 1) == "#" then
        color = string.sub(color, 2)
    end
    return "group_hl_" .. color
end

local function add_highlight_group(color)
    local group = color_to_highlight_group(color)
    vim.api.nvim_set_hl(0, group, { bg = color, fg = 'Black' })
end

local hl_colors = {}
for i, color in ipairs(config.colors) do
    add_highlight_group(color)
    hl_colors[color] = {pattern = "", id = 9999+i}
end

local function highlight(input_pattern)
    local first_available_color = nil
    for color, c in pairs(hl_colors) do
        if c.pattern == "" and first_available_color == nil then
            first_available_color = color
        end

        if input_pattern == c.pattern then
            return
        end
    end

    if first_available_color == nil then
        print("no color available")
    else
        local color = first_available_color
        local group = color_to_highlight_group(color)
        local c = hl_colors[color]
        for i = 1, vim.fn.winnr('$') do
            pcall(function()
                add_highlight_group(color)
                vim.fn.matchadd(group, input_pattern, 1, c.id, {window = i})
            end)
        end
        hl_colors[color].pattern = input_pattern
    end
end

local function highlight_clear_all()
    for _, c in pairs(hl_colors) do
        if c.pattern ~= "" then
            for i = 1, vim.fn.winnr('$') do
                pcall(function()
                    vim.fn.matchdelete(c.id, i)
                end)
            end
            c.pattern = ""
        end
    end
end

vim.api.nvim_create_user_command("HL", function(params)
    highlight(params.fargs[1])
end, { nargs = "?", range = false, desc = "高亮" })

vim.api.nvim_create_user_command("HLClearAll", function()
    highlight_clear_all()
end, { nargs = "?", range = false, desc = "清除高亮" })
