local Session = require("gpt.sessions")
local buffers = require("gpt.buffers")

local actions = {}

local config = {
    current_session_file = vim.fn.stdpath("data"):gsub("/$", "") .. "/gpt/sessions/current.md",
    default_model = "gpt-4",
    default_temperature = 0.2,
}

function actions.setup(user_config)
    config = vim.tbl_deep_extend("force", config, user_config or {})
end

-- 运行命名
---@param params table neovim visual的params
---@param command string 给chatgpt的命令（prompt） 
---@param action string 动作
---       newbuffer: 在新buffer中输出回答
---       replace: 替换当前buffer中选中的内容
function actions.run_command(params, command, action)
    local callback = function(callback_command)
	    -- get current buffer
	    local buf = vim.api.nvim_get_current_buf()

	    local selection = nil
        local start_line, end_line

	    -- handle range
	    if params.range == 2 then
	    	start_line = params.line1
	    	end_line = params.line2
	    	local lines = vim.api.nvim_buf_get_lines(buf, start_line - 1, end_line, false)
	    	selection = table.concat(lines, "\n")
        else
	        start_line = vim.api.nvim_win_get_cursor(0)[1]
	        end_line = start_line
	    end

        local session = nil

        local current_session_file = config.current_session_file
        if vim.fn.filereadable(current_session_file) == 1 then
            current_session_file = vim.fn.resolve(current_session_file)
            session = Session:from_file(current_session_file)
            if session == nil then
                print("Error: load session from file")
                return
            end
        else
            session = Session:new({model = config.default_model, temperature = config.default_temperature})
        end


        local content = callback_command .. "\n"
        if selection ~= nil then
            content = content .. "\n```" .. selection .. "```\n\n"
        end

        local cb
        if action == "replace" then
			-- 删除选中
            buffers.delete_lines(buf, start_line, end_line)

            -- append到当前buffer
	        vim.cmd("stopinsert")

            local h = buffers.create_stream_insert_handler(buf, start_line-1)
            cb = function(text, state)
                if state == "START" or state == "CONTINUE" then
                    h(text)
                end
            end
        elseif action == "newbuffer" then
            vim.cmd("stopinsert")
			local buffer = vim.api.nvim_create_buf(true, false)
			vim.api.nvim_set_current_buf(buffer)
			vim.api.nvim_buf_set_option(buffer, "filetype", "markdown")

            cb = function(text, state)
                if state == "START" or state == "CONTINUE" then
                    local callback_lines = vim.split(text, "\n", {})
                    local length = #callback_lines

                    for i, callback_line in ipairs(callback_lines) do
                        local current_line = vim.api.nvim_buf_get_lines(buffer, -2, -1, false)[1]
                        vim.api.nvim_buf_set_lines(buffer, -2, -1, false, { current_line .. callback_line })

                        if i == length and i > 1 then
                            vim.api.nvim_buf_set_lines(buffer, -1, -1, false, { "" })
                        end
                    end
                end
            end
        end

        session:ask(content, cb)
    end

	vim.schedule(function()
        if command == nil or command == "" then
		    vim.ui.input({ prompt = "" }, function(input)
		    	if not input or input == "" then
		    		return
		    	end
		    	callback(input)
		    end)
        else
            callback(command)
        end
	end)
end

-- 加载当前buffer（md文件）的session，并继续
function actions.run_session()
	vim.cmd("stopinsert")
    local buffer = vim.api.nvim_get_current_buf()
    local session = Session:from_buf(buffer)
    session:run(buffer)
end

return actions
