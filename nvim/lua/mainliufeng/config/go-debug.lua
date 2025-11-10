local M = {}

-- 默认调试配置
local default_config = {
    program = "${workspaceFolder}",
    args = "",
    env = "",
    cwd = "${workspaceFolder}",
    build_flags = "",
    mode = "debug", -- debug 或 test
}

-- 解析环境变量字符串为table
local function parse_env_string(env_str)
    local env = {}
    if env_str and env_str ~= "" then
        for pair in env_str:gmatch("[^,]+") do
            local key, value = pair:match("([^=]+)=([^=]*)")
            if key and value then
                env[vim.trim(key)] = vim.trim(value)
            end
        end
    end
    return env
end

-- 解析参数字符串为table
local function parse_args_string(args_str)
    local args = {}
    if args_str and args_str ~= "" then
        for arg in args_str:gmatch("%S+") do
            table.insert(args, arg)
        end
    end
    return args
end

-- 创建调试配置的交互式界面
function M.setup_debug_with_ui()
    local config = vim.deepcopy(default_config)
    local prompts = {
        {
            key = "mode",
            prompt = "调试模式 (debug/test): ",
            default = config.mode,
        },
        {
            key = "program", 
            prompt = "程序路径 (按回车使用当前目录): ",
            default = config.program,
        },
        {
            key = "args",
            prompt = "程序参数 (用空格分隔): ",
            default = config.args,
        },
        {
            key = "env",
            prompt = "环境变量 (格式: KEY1=value1,KEY2=value2): ",
            default = config.env,
        },
        {
            key = "cwd",
            prompt = "工作目录 (按回车使用当前目录): ",
            default = config.cwd,
        },
        {
            key = "build_flags",
            prompt = "构建标志 (如: -tags=integration): ",
            default = config.build_flags,
        },
    }
    
    local function collect_input(index)
        if index > #prompts then
            -- 所有输入收集完成，启动调试
            M.start_debug_with_config(config)
            return
        end
        
        local current = prompts[index]
        vim.ui.input({
            prompt = current.prompt,
            default = current.default,
        }, function(input)
            if input ~= nil then
                config[current.key] = input ~= "" and input or current.default
            end
            collect_input(index + 1)
        end)
    end
    
    collect_input(1)
end

-- 使用配置启动调试
function M.start_debug_with_config(config)
    local dap = require('dap')
    
    -- 构建调试配置
    local debug_config = {
        type = "go",
        name = "Debug with custom config",
        request = "launch",
        program = config.program,
        args = parse_args_string(config.args),
        env = parse_env_string(config.env),
        cwd = config.cwd,
    }
    
    -- 添加构建标志
    if config.build_flags ~= "" then
        debug_config.buildFlags = config.build_flags
    end
    
    -- 根据模式调整配置
    if config.mode == "test" then
        debug_config.mode = "test"
        debug_config.program = "./${relativeFileDirname}"
    end
    
    -- 启动调试会话
    dap.run(debug_config)
end

-- 快速调试预设配置
function M.setup_quick_debug_presets()
    local dap = require('dap')
    
    -- 添加预设配置到 dap.configurations.go
    dap.configurations.go = dap.configurations.go or {}
    
    -- 合并新配置
    local new_configs = {
        {
            type = "go",
            name = "🚀 交互式调试 (自定义参数)",
            request = "launch",
            program = function()
                M.setup_debug_with_ui()
                return dap.ABORT -- 中止默认启动，使用自定义流程
            end,
        },
        {
            type = "go",
            name = "🏠 调试当前main包",
            request = "launch",
            program = "${workspaceFolder}",
        },
        {
            type = "go",
            name = "📁 调试当前文件目录",
            request = "launch", 
            program = "./${relativeFileDirname}",
        },
        {
            type = "go",
            name = "🧪 运行当前测试",
            request = "launch",
            mode = "test",
            program = "./${relativeFileDirname}",
        },
        {
            type = "go",
            name = "🔧 调试并传入参数",
            request = "launch",
            program = "${workspaceFolder}",
            args = function()
                local input = vim.fn.input('程序参数: ')
                return vim.split(input, ' ')
            end,
        },
        {
            type = "go",
            name = "🌍 调试带环境变量",
            request = "launch",
            program = "${workspaceFolder}",
            env = function()
                local env_input = vim.fn.input('环境变量 (KEY=value,KEY2=value2): ')
                return parse_env_string(env_input)
            end,
        },
    }
    
    -- 将新配置添加到现有配置
    for _, config in ipairs(new_configs) do
        table.insert(dap.configurations.go, config)
    end
end

return M