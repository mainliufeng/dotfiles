local iter = require("plenary.iterators")
local scan = require("plenary.scandir")
local path = require("plenary.path")

local last_git_output = nil

local function notify(message, level)
    vim.notify(message, level or vim.log.levels.INFO, { title = "Git" })
end

local function git_root()
    local cwd = vim.fn.getcwd()
    return vim.fs.root(cwd, { ".git" }) or cwd
end

local function git_dir(root)
    local result = vim.system({ "git", "-C", root, "rev-parse", "--absolute-git-dir" }, {
        text = true,
        env = vim.tbl_extend("force", vim.fn.environ(), {
            GIT_TERMINAL_PROMPT = "0",
        }),
    }):wait()

    if result.code ~= 0 then
        local output = vim.trim(((result.stderr or "") .. "\n" .. (result.stdout or "")))
        return nil, output ~= "" and output or "not a git repository"
    end

    return vim.trim(result.stdout), nil
end

local function get_buffer_var(buffer, name)
    local ok, value = pcall(vim.api.nvim_buf_get_var, buffer, name)
    if ok then
        return true, value
    end

    return false, nil
end

local function restore_buffer_var(buffer, name, had_value, value)
    if had_value then
        vim.api.nvim_buf_set_var(buffer, name, value)
    else
        pcall(vim.api.nvim_buf_del_var, buffer, name)
    end
end

local function run_fugitive(args)
    local root = git_root()
    local dir, err = git_dir(root)

    if dir == nil then
        notify(("Git failed in %s: %s"):format(vim.fn.fnamemodify(root, ":~:."), err), vim.log.levels.ERROR)
        return
    end

    local buffer = vim.api.nvim_get_current_buf()
    local had_git_dir, previous_git_dir = get_buffer_var(buffer, "git_dir")

    vim.api.nvim_buf_set_var(buffer, "git_dir", dir)

    local ok, command_err = pcall(function()
        if args == nil or args == "" then
            vim.cmd("Git")
        else
            vim.cmd("Git " .. args)
        end
    end)

    if vim.api.nvim_buf_is_valid(buffer) then
        restore_buffer_var(buffer, "git_dir", had_git_dir, previous_git_dir)
    end

    if not ok then
        notify(tostring(command_err), vim.log.levels.ERROR)
    end
end

local function split_output(text)
    if text == nil or text == "" then
        return {}
    end
    return vim.split(vim.trim(text), "\n", { plain = true })
end

local function compact_output(result)
    local lines = {}
    vim.list_extend(lines, split_output(result.stdout))
    vim.list_extend(lines, split_output(result.stderr))
    return lines
end

local function first_meaningful_line(lines, fallback)
    for _, line in ipairs(lines) do
        if vim.trim(line) ~= "" then
            return vim.trim(line)
        end
    end
    return fallback
end

local function show_last_git_output()
    if last_git_output == nil then
        notify("No git command output yet", vim.log.levels.WARN)
        return
    end

    local width = math.min(math.floor(vim.o.columns * 0.82), 110)
    local height = math.min(
        math.max(#last_git_output.lines + 2, 8),
        math.floor(vim.o.lines * 0.65)
    )
    local row = math.floor((vim.o.lines - height) / 3)
    local col = math.floor((vim.o.columns - width) / 2)

    local buffer = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, last_git_output.lines)
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buffer })
    vim.api.nvim_set_option_value("filetype", "git", { buf = buffer })
    vim.api.nvim_set_option_value("modifiable", false, { buf = buffer })

    vim.api.nvim_open_win(buffer, true, {
        relative = "editor",
        row = row,
        col = col,
        width = width,
        height = height,
        border = "rounded",
        style = "minimal",
        title = " " .. last_git_output.title .. " ",
        title_pos = "center",
    })
end

local function fugitive_status_section()
    local row = vim.api.nvim_win_get_cursor(0)[1]

    for lnum = row, 1, -1 do
        local line = vim.api.nvim_buf_get_lines(0, lnum - 1, lnum, false)[1] or ""
        local section = line:match("^([%a ]+) %(%d+%)$")
        if section then
            return vim.trim(section)
        end
    end

    return nil
end

local function is_fugitive_file_line(line)
    return line:match("^[MADRCU?][MADRCU? ]?%s+") ~= nil
end

local function add_help_section(lines, title, mappings)
    table.insert(lines, title)
    for _, mapping in ipairs(mappings) do
        table.insert(lines, ("  %-10s %s"):format(mapping[1], mapping[2]))
    end
    table.insert(lines, "")
end

local fugitive_status_help = {
    buffer = nil,
    window = nil,
}

local function fugitive_context_help_content()
    local line = vim.api.nvim_get_current_line()
    local section = fugitive_status_section()
    local file_line = is_fugitive_file_line(line)
    local title = section and ("Fugitive: " .. section) or "Fugitive"
    local lines = {}

    if file_line then
        if section == "Unstaged" or section == "Untracked" then
            add_help_section(lines, "Current file", {
                { "s", "stage file or hunk" },
                { "-", "stage / unstage toggle" },
                { "X", "discard change under cursor" },
                { "=", "toggle inline diff" },
                { "I", "add/reset patch for file" },
                { "gI", "ignore file in .git/info/exclude" },
            })
        elseif section == "Staged" then
            add_help_section(lines, "Current file", {
                { "u", "unstage file or hunk" },
                { "-", "stage / unstage toggle" },
                { "=", "toggle inline diff" },
                { "I", "add/reset patch for file" },
            })
        else
            add_help_section(lines, "Current item", {
                { "<CR>", "open file or object" },
                { "=", "toggle inline diff when available" },
                { "coo", "checkout commit under cursor" },
                { "crc", "revert commit under cursor" },
            })
        end

        add_help_section(lines, "Open / diff", {
            { "<CR>", "open" },
            { "o", "open in split" },
            { "gO", "open in vertical split" },
            { "O", "open in tab" },
            { "p", "open preview" },
            { "dd", "diff split" },
            { "dv", "vertical diff" },
            { "ds", "horizontal diff" },
            { "dq", "close diffs" },
        })
    elseif section then
        add_help_section(lines, "Section", {
            { "gu", "jump to untracked / unstaged" },
            { "gU", "jump to unstaged" },
            { "gs", "jump to staged" },
            { "gp", "jump to unpushed" },
            { "gP", "jump to unpulled" },
            { "gr", "jump to rebasing" },
        })
    else
        add_help_section(lines, "Status", {
            { "cc", "commit" },
            { "ca", "amend commit" },
            { "czz", "stash" },
            { "czp", "stash pop" },
            { "U", "unstage everything" },
        })
    end

    add_help_section(lines, "Navigate / help", {
        { ")", "next file / hunk / revision" },
        { "(", "previous file / hunk / revision" },
        { "]c", "next hunk" },
        { "[c", "previous hunk" },
        { "g?", "full fugitive help" },
        { "gq", "close status buffer" },
    })

    while lines[#lines] == "" do
        table.remove(lines)
    end

    return title, lines
end

local function close_fugitive_context_help()
    if fugitive_status_help.window and vim.api.nvim_win_is_valid(fugitive_status_help.window) then
        vim.api.nvim_win_close(fugitive_status_help.window, true)
    end

    fugitive_status_help.window = nil
    fugitive_status_help.buffer = nil
end

local function show_fugitive_context_help()
    if vim.bo.filetype ~= "fugitive" or vim.b.fugitive_type ~= "index" then
        close_fugitive_context_help()
        return
    end

    local title, lines = fugitive_context_help_content()
    local win_width = vim.api.nvim_win_get_width(0)
    local win_height = vim.api.nvim_win_get_height(0)
    local width = math.min(48, math.max(28, math.floor(win_width * 0.36)))
    local height = math.min(#lines, math.max(8, math.floor(win_height * 0.6)))
    local col = math.max(0, win_width - width - 2)

    if not fugitive_status_help.buffer or not vim.api.nvim_buf_is_valid(fugitive_status_help.buffer) then
        fugitive_status_help.buffer = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = fugitive_status_help.buffer })
        vim.api.nvim_set_option_value("filetype", "text", { buf = fugitive_status_help.buffer })
    end

    vim.api.nvim_set_option_value("modifiable", true, { buf = fugitive_status_help.buffer })
    vim.api.nvim_buf_set_lines(fugitive_status_help.buffer, 0, -1, false, lines)
    vim.api.nvim_set_option_value("modifiable", false, { buf = fugitive_status_help.buffer })

    local config = {
        relative = "win",
        row = 1,
        col = col,
        width = width,
        height = height,
        border = "rounded",
        style = "minimal",
        title = " " .. title .. " ",
        title_pos = "center",
        focusable = false,
        noautocmd = true,
    }

    if fugitive_status_help.window and vim.api.nvim_win_is_valid(fugitive_status_help.window) then
        vim.api.nvim_win_set_config(fugitive_status_help.window, config)
        vim.api.nvim_set_option_value("winblend", 12, { win = fugitive_status_help.window })
        return
    end

    fugitive_status_help.window = vim.api.nvim_open_win(fugitive_status_help.buffer, false, config)
    vim.api.nvim_set_option_value("winblend", 12, { win = fugitive_status_help.window })
end

local function run_git_async(args, title)
    local root = git_root()
    local started = vim.loop.hrtime()

    notify(title .. " started in " .. vim.fn.fnamemodify(root, ":~:."))

    vim.system(vim.list_extend({ "git" }, args), {
        cwd = root,
        text = true,
        env = vim.tbl_extend("force", vim.fn.environ(), {
            GIT_TERMINAL_PROMPT = "0",
        }),
    }, function(result)
        vim.schedule(function()
            local lines = compact_output(result)
            if #lines == 0 then
                lines = { "(no output)" }
            end

            local elapsed = (vim.loop.hrtime() - started) / 1e9
            local heading = ("%s (%s, %.1fs)"):format(title, root, elapsed)
            local body = vim.list_extend({ heading, "" }, lines)
            last_git_output = {
                title = title,
                lines = body,
            }

            if result.code == 0 then
                notify(("%s done: %s"):format(title, first_meaningful_line(lines, "ok")))
            else
                notify(
                    ("%s failed: %s"):format(title, first_meaningful_line(lines, "exit " .. result.code)),
                    vim.log.levels.ERROR
                )
                show_last_git_output()
            end
        end)
    end)
end

vim.api.nvim_create_user_command("Gst", function()
    run_fugitive()
end, { desc = "git status" })

vim.api.nvim_create_user_command("Gup", function()
    run_git_async({ "pull", "--rebase" }, "git pull --rebase")
end, { desc = "git pull --rebase" })

vim.api.nvim_create_user_command("Gp", function()
    run_git_async({ "push" }, "git push")
end, { desc = "git push" })

vim.api.nvim_create_user_command("Gout", show_last_git_output, { desc = "show last git command output" })

local fugitive_status_help_group = vim.api.nvim_create_augroup("mainliufeng_fugitive_status_help", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
    group = fugitive_status_help_group,
    pattern = "fugitive",
    callback = function(event)
        if vim.b[event.buf].fugitive_type ~= "index" then
            return
        end

        if vim.b[event.buf].mainliufeng_fugitive_help_attached then
            return
        end

        vim.b[event.buf].mainliufeng_fugitive_help_attached = true

        vim.keymap.set("n", "?", show_fugitive_context_help, {
            buffer = event.buf,
            desc = "Context help",
        })

        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            group = fugitive_status_help_group,
            buffer = event.buf,
            callback = show_fugitive_context_help,
        })

        vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "BufWinLeave" }, {
            group = fugitive_status_help_group,
            buffer = event.buf,
            callback = close_fugitive_context_help,
        })

        vim.schedule(show_fugitive_context_help)
    end,
})

local git_aliases = {
    Gd = {
        args = "diff",
        desc = "git diff",
    },
    Glg = {
        args = "log --stat",
        desc = "git log --stat",
    },
}

for name, alias in pairs(git_aliases) do
    vim.api.nvim_create_user_command(name, function()
        run_fugitive(alias.args)
    end, { desc = alias.desc })
end

local function get_repos(base_dirs)
    return iter.iter(base_dirs)
        :map(function(base_dir)
            local git_dirs = scan.scan_dir(vim.fn.expand(base_dir.path), {
                depth = base_dir.max_depth,
                add_dirs = true,
                hidden = true,
                search_pattern = "%.git$"
            })
            return iter.iter(git_dirs)
                :map(function(git_dir) return path:new(git_dir):parent() end)
        end)
        :flatten()
        :map(function(repo) return tostring(repo) end)
        :tolist()
end

local function get_repos_branches(base_dirs)
    local repos = get_repos(base_dirs)
    local ret = {}

    for _, repo in ipairs(repos) do
        local branches = vim.fn.systemlist('git -C ' .. repo .. ' for-each-ref refs/heads/ --format="%(refname:short)"')
        for _, branch in ipairs(branches) do
            if ret[branch] == nil then
                ret[branch] = {}
            end
            table.insert(ret[branch], repo)
        end
    end

    return ret
end

vim.api.nvim_create_user_command("GitsBranchDesc", function()
    local base_dirs = {}
    table.insert(base_dirs, {
        path = "~/Code",
        max_depth = 3,
    })
    local repos_branches = get_repos_branches(base_dirs)

    local items = {}
    local options = {}
    for branch, repos in pairs(repos_branches) do
        table.insert(items, branch)
        table.insert(options, {
            value = branch,
            preview = table.concat(repos, '\n')
        })
    end

    local show = function(branch)
        local buffer_id = vim.api.nvim_create_buf(true, true)
        local repos = repos_branches[branch]

        for _, repo in ipairs(repos) do
            local command = 'git -C ' .. repo .. ' log `git -C ' .. repo .. ' rev-parse --abbrev-ref ' .. branch .. '@{upstream}`..' .. branch
            print(command)
            local command_output = vim.fn.systemlist(command)
            local output = {}
            table.insert(output, '#' .. repo)
            table.insert(output, '')
            table.insert(output, '```')
            for _, line in ipairs(command_output) do
                table.insert(output, line)
            end
            table.insert(output, '```')
            table.insert(output, '')
            vim.api.nvim_buf_set_lines(buffer_id, -1, -1, true, output)
        end

        -- 打开只读 buffer
        vim.api.nvim_open_win(buffer_id, true, {
            relative = 'win',
            row = 0,
            col = 0,
            width = vim.fn.winwidth(0),
            height = vim.fn.winheight(0),
            style = 'minimal'
        })

        -- 设置 buffer 为只读模式
        vim.api.nvim_buf_set_option(buffer_id, 'modifiable', false)
        vim.api.nvim_buf_set_option(buffer_id, 'filetype', 'markdown')
    end

    vim.ui.select(items, {
        prompt="选择一个分支：",
        telescope = require("telescope.themes").get_dropdown(),
    }, show)

end, { nargs = "?", range = false, desc = "分支描述(多repo)" })
