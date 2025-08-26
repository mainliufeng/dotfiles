-- windsurf.vim configuration
-- AI-powered code completion integration with blink.cmp

-- windsurf.vim 全局配置
vim.g.codeium_enabled = true
vim.g.codeium_manual = false  -- 自动触发，不需要手动

-- 让 windsurf 使用默认 Tab 键，但优先级比 blink 低
-- 这样当 blink 补全菜单可见时，blink 处理 Tab；否则 windsurf 处理

-- 备用快捷键映射 (推荐使用这些以避免冲突)
vim.keymap.set('i', '<M-CR>', function() return vim.fn['codeium#Accept']() end, { expr = true, silent = true })
vim.keymap.set('i', '<M-]>', function() return vim.fn['codeium#CycleCompletions'](1) end, { expr = true, silent = true })
vim.keymap.set('i', '<M-[>', function() return vim.fn['codeium#CycleCompletions'](-1) end, { expr = true, silent = true })
vim.keymap.set('i', '<M-x>', function() return vim.fn['codeium#Clear']() end, { expr = true, silent = true })
vim.keymap.set('i', '<M-w>', function() return vim.fn['codeium#AcceptNextWord']() end, { expr = true, silent = true })
vim.keymap.set('i', '<M-l>', function() return vim.fn['codeium#AcceptNextLine']() end, { expr = true, silent = true })

-- 文件类型配置 (通过 autocmd 实现)
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "text", "gitcommit" },
    callback = function()
        vim.b.codeium_enabled = false
    end,
})

-- 状态显示函数
function CodeiumStatus()
    return vim.fn['codeium#GetStatusString']()
end

-- 设置状态行显示
vim.g.codeium_status_string = CodeiumStatus
