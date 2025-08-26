-- windsurf.nvim configuration
-- AI-powered code completion integration with blink.cmp

-- windsurf.nvim setup
require("codeium").setup({
    -- 禁用与 nvim-cmp 的集成，因为我们使用 blink.cmp
    enable_cmp_source = false,
    
    -- 虚拟文本配置
    virtual_text = {
        enabled = true,
        -- 自定义快捷键避免与 blink 冲突
        key_bindings = {
            -- 使用 Alt 组合键避免冲突
            accept = "<M-CR>",           -- Alt+Enter 接受建议
            next = "<M-]>",              -- Alt+] 下一个建议  
            prev = "<M-[>",              -- Alt+[ 上一个建议
            clear = "<M-x>",             -- Alt+x 清除建议
            accept_word = "<M-w>",       -- Alt+w 接受单词
            accept_line = "<M-l>",       -- Alt+l 接受行
        },
        -- 文件类型配置
        filetypes = {
            -- 为主要编程语言启用
            python = true,
            javascript = true,
            typescript = true,
            go = true,
            rust = true,
            lua = true,
            c = true,
            cpp = true,
            java = true,
            -- 对某些文件类型禁用
            markdown = false,
            text = false,
            gitcommit = false,
        },
        default_filetype_enabled = true,
        
        -- UI 配置
        idle_delay = 75,               -- 延迟触发时间（毫秒）
        manual = false,                -- 自动触发，不需要手动
    },
    
    -- 工具配置
    tools = {
        -- 可以配置额外的 windsurf 工具
    }
})

-- 设置状态行显示
vim.g.codeium_status_string = function()
    return require('codeium.virtual_text').status_string()
end