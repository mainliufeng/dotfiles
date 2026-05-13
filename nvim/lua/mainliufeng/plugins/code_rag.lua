local M = {}

local function command_path()
    local local_cmd = vim.fn.expand("~/dotfiles/scripts/code-rag")
    if vim.fn.executable(local_cmd) == 1 then
        return local_cmd
    end
    return "code-rag"
end

local function root_dir()
    local root = vim.fs.root(0, { ".git" })
    return root or vim.fn.getcwd()
end

local function notify(message, level)
    vim.notify(message, level or vim.log.levels.INFO, { title = "code-rag" })
end

local function run(args, on_exit)
    vim.system(vim.list_extend({ command_path() }, args), { text = true }, function(result)
        vim.schedule(function()
            on_exit(result)
        end)
    end)
end

local function jump_to_item(item)
    local filename = root_dir() .. "/" .. item.path
    vim.cmd.edit(vim.fn.fnameescape(filename))
    vim.api.nvim_win_set_cursor(0, { item.start, 0 })
    vim.cmd.normal({ "zz", bang = true })
end

function M.index(opts)
    opts = opts or {}
    local root = root_dir()
    local args = { "--root", root, "index", "--json" }
    if opts.force then
        table.insert(args, "--force")
    end

    notify("Indexing " .. root)
    run(args, function(result)
        if result.code ~= 0 then
            notify((result.stderr ~= "" and result.stderr or result.stdout), vim.log.levels.ERROR)
            return
        end

        local ok, stats = pcall(vim.json.decode, result.stdout)
        if ok and stats then
            notify(("Indexed %d chunks from %d files in %.2fs"):format(stats.chunks or 0, stats.files or 0, stats.seconds or 0))
        else
            notify("Index updated")
        end
    end)
end

local function make_picker(query, items, opts)
    opts = opts or {}
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")

    pickers.new({}, {
        prompt_title = (opts.code_only and "Semantic code search: " or "Semantic search: ") .. query,
        finder = finders.new_table({
            results = items,
            entry_maker = function(item)
                local filename = root_dir() .. "/" .. item.path
                local score = tonumber(item.score) or 0
                return {
                    value = item,
                    ordinal = table.concat({ item.path, item.preview or "", tostring(item.start), tostring(item["end"]) }, " "),
                    display = ("%0.3f  %s:%d  %s"):format(score, item.path, item.start, item.preview or ""),
                    filename = filename,
                    lnum = item.start,
                    col = 1,
                }
            end,
        }),
        sorter = conf.generic_sorter({}),
        previewer = conf.grep_previewer({}),
        attach_mappings = function(prompt_bufnr)
            actions.select_default:replace(function()
                local selection = action_state.get_selected_entry()
                actions.close(prompt_bufnr)
                if not selection then
                    return
                end
                jump_to_item(selection.value)
            end)
            return true
        end,
    }):find()
end

local function search_items(query, limit, opts, on_items)
    if not query or query == "" then
        return
    end
    opts = opts or {}
    local root = root_dir()
    notify("Searching " .. root)
    local args = { "--root", root, "search", "--auto-index", "--json", "--limit", tostring(limit) }
    if opts.code_only then
        table.insert(args, "--code-only")
    end
    table.insert(args, query)
    run(args, function(result)
        if result.code ~= 0 then
            notify((result.stderr ~= "" and result.stderr or result.stdout), vim.log.levels.ERROR)
            return
        end

        local ok, items = pcall(vim.json.decode, result.stdout)
        if not ok or type(items) ~= "table" then
            notify("Could not parse search results", vim.log.levels.ERROR)
            return
        end
        if #items == 0 then
            notify("No semantic matches")
            return
        end
        on_items(items)
    end)
end

function M.search(opts)
    opts = opts or { code_only = true }
    local default = vim.fn.expand("<cword>")
    vim.ui.input({ prompt = "Semantic search > ", default = default }, function(query)
        search_items(query, 30, opts, function(items)
            make_picker(query, items, opts)
        end)
    end)
end

function M.open(query)
    local function open_query(input)
        search_items(input, 1, { code_only = true }, function(items)
            local item = items[1]
            jump_to_item(item)
            notify(("Opened %s:%d  %.3f"):format(item.path, item.start, tonumber(item.score) or 0))
        end)
    end

    if query and query ~= "" then
        open_query(query)
        return
    end

    vim.ui.input({ prompt = "Open semantic match > ", default = vim.fn.expand("<cword>") }, open_query)
end

function M.status()
    local root = root_dir()
    run({ "--root", root, "status" }, function(result)
        local message = result.code == 0 and result.stdout or (result.stderr ~= "" and result.stderr or result.stdout)
        notify(message, result.code == 0 and vim.log.levels.INFO or vim.log.levels.WARN)
    end)
end

function M.setup()
    vim.api.nvim_create_user_command("CodeRagSearch", function()
        M.search({ code_only = true })
    end, {})
    vim.api.nvim_create_user_command("CodeRagSearchAll", function()
        M.search({ code_only = false })
    end, {})
    vim.api.nvim_create_user_command("CodeRagOpen", function(opts)
        M.open(opts.args)
    end, { nargs = "*" })
    vim.api.nvim_create_user_command("CodeRagIndex", function()
        M.index()
    end, {})
    vim.api.nvim_create_user_command("CodeRagReindex", function()
        M.index({ force = true })
    end, {})
    vim.api.nvim_create_user_command("CodeRagStatus", function()
        M.status()
    end, {})
end

return M
