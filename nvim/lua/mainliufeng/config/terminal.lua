local M = {}

local function normalize_count(count)
    if type(count) ~= "number" or count < 1 then
        return 1
    end
    return math.floor(count)
end

local function terminal_opts(count)
    local idx = normalize_count(count)
    return {
        env = { SNACKS_TERMINAL_INDEX = tostring(idx) },
        win = {
            position = "float",
        },
    }
end

local function ensure_terminal(count)
    local Snacks = require("snacks")
    local opts = terminal_opts(count)
    local term = Snacks.terminal.get(nil, opts)
    if not term then
        return nil
    end
    term:show()
    return term
end

function M.toggle(count)
    local Snacks = require("snacks")
    local opts = terminal_opts(count)
    return Snacks.terminal(nil, opts)
end

local function get_visual_text()
    local start_pos = vim.api.nvim_buf_get_mark(0, "<")
    local end_pos = vim.api.nvim_buf_get_mark(0, ">")
    if not start_pos or not end_pos then
        return nil
    end
    if start_pos[1] > end_pos[1] or (start_pos[1] == end_pos[1] and start_pos[2] > end_pos[2]) then
        start_pos, end_pos = end_pos, start_pos
    end
    local lines = vim.api.nvim_buf_get_lines(0, start_pos[1] - 1, end_pos[1], false)
    if vim.tbl_isempty(lines) then
        return nil
    end

    local mode = vim.fn.visualmode()
    local end_col = end_pos[2]
    if mode == "V" then
        end_col = math.huge
    end

    lines[#lines] = lines[#lines]:sub(1, math.min(end_col + 1, #lines[#lines]))
    lines[1] = lines[1]:sub(start_pos[2] + 1)

    -- trim for block selection
    if mode == "\22" then -- visual block
        for i, line in ipairs(lines) do
            local from = start_pos[2] + 1
            local to = math.min(end_pos[2] + 1, #line)
            lines[i] = line:sub(from, to)
        end
    end

    local text = table.concat(lines, "\n")
    if not text:match("\n$") then
        text = text .. "\n"
    end
    return text
end

function M.send_visual(count)
    local text = get_visual_text()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
    if not text or text == "\n" then
        return
    end
    local term = ensure_terminal(count)
    if not term or not term:buf_valid() then
        term = M.toggle(count)
    end
    if not term or not term:buf_valid() then
        return
    end
    local job = vim.b[term.buf].terminal_job_id
    if job then
        vim.fn.chansend(job, text)
    end
    term:show()
end

return M
