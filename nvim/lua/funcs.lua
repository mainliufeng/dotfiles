vim.api.nvim_create_user_command("GitsBranchDesc", function(params)
    -- 创建一个只读 buffer
    local buffer_id = vim.api.nvim_create_buf(false, true)

    -- 执行 shell 命令并捕获输出
    local command_output = vim.fn.systemlist('gits-branch-desc ' .. params.args)

    -- 将命令输出写入 buffer 中
    vim.api.nvim_buf_set_lines(buffer_id, 0, -1, false, command_output)

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
end, { nargs = "?", range = false, desc = "Show branch git commits of multiple git repos" })
