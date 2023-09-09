local iter = require("plenary.iterators")
local scan = require("plenary.scandir")
local path = require("plenary.path")

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
