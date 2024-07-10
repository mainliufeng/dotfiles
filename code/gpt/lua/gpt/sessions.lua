local client = require("gpt.openai_client")

local Session = {
    model = "",
    temperature = 0.0,
    messages = {},
}

function Session:new(o)
    local session = setmetatable(o or {}, self)
    self.__index = self

    self.modes = {
        model = {role = "", prefix =  "# Model"},
        system = {role = "system", prefix =  "# System"},
        user = {role = "user", prefix =  "# User"},
        assistant = {role = "assistant", prefix =  "# Assistant"},
    }

    return session
end

function Session:prefix_to_mode(prefix)
    for _, mode in pairs(self.modes) do
        if mode.prefix == prefix then
            return mode
        end
    end
end

function Session:role_to_mode(role)
    for _, mode in pairs(self.modes) do
        if mode.role == role then
            return mode
        end
    end
end

function Session:from_file(file_path)
    local file = io.open(file_path, "r") -- 打开文件
    if file then
        local session = Session:from_lines(file:lines())
        file:close() -- 关闭文件
        return session
    end
    return nil
end

function Session:from_buf(buffer)
	local buffer_lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
    return Session:from_lines(buffer_lines)
end

function Session:from_lines(lines)
    local session = Session:new({})
    session.messages = {}

	local content = ""
    local mode

    local parse_content = function()
        if mode ~= nil then
            if mode == self.modes.model then
                local model_lines = vim.split(content, "\n", {})
	            for _, model_line in ipairs(model_lines) do
                    local ok, json = pcall(vim.json.decode, model_line)
                    if ok and json ~= nil then
                        if json.model ~= nil then
                            session.model = json.model
                        end
                        if json.temperature ~= nil then
                            session.temperature = json.temperature
                        end
                    end
                end
            elseif mode == self.modes.system then
                session:append_message(self.modes.system.role, content)
            elseif mode == self.modes.user then
                session:append_message(self.modes.user.role, content)
            elseif mode == self.modes.assistant then
                session:append_message(self.modes.assistant.role, content)
            end
        end

    end

	for _, line in ipairs(lines) do
        local prefix = line:match("^(# %w+)")
        local maybe_mode = self:prefix_to_mode(prefix)
        if maybe_mode ~= nil then
            parse_content()
            mode = maybe_mode
            content = ""
        else
            content = content .. "\n" .. line
        end
	end

    if content ~= "" then
        parse_content()
    end

    return session
end

function Session:to_buf(buffer)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, self:to_lines())
end

function Session:to_lines()
    local lines = {
        self.modes.model.prefix,
        "",
        vim.json.encode({model = self.model, temperature = self.temperature}),
        "",
    }

    for _, message in ipairs(self.messages) do
        if message.content ~= nil then
            local content = message.content:gsub("^%s*(.-)%s*$","%1")

            if content ~= "" then
                table.insert(lines, self:role_to_mode(message.role).prefix)
                table.insert(lines, "")

                local content_lines = vim.split(content, "\n", {})
                for _, content_line in ipairs(content_lines) do
                    table.insert(lines, content_line)
                end

                table.insert(lines, "")
            end
        end
    end

    return lines
end

function Session:append_message(role, content)
    table.insert(self.messages, {
        role = role,
        content = content,
    })
end

function Session:ask(prompt, callback)
    self:append_message(self.modes.user.role, prompt)
    self:do_request(callback)
end

function Session:do_request(callback)
    local length = #self.messages
    if length == 0 then
        return
    end

    local last_message = self.messages[length]
    if last_message.role == self.modes.assistant.role then
        return
    end

    client.do_request(self, function(text, state)
        callback(text, state)
        if state == "END" then
            self:append_message(self.modes.assistant.role, text)
        elseif state == "ERROR" then
            print(text)
        end
    end)
end

function Session:run(buffer)
    local callback = function(text, state)
        if state == "START" or state == "CONTINUE" then
            local callback_lines = vim.split(text, "\n", {})
            local length = #callback_lines

            for i, callback_line in ipairs(callback_lines) do
                local current_line = vim.api.nvim_buf_get_lines(buffer, -2, -1, false)[1]
                vim.api.nvim_buf_set_lines(buffer, -2, -1, false, { current_line .. callback_line })

                if i < length then
                    vim.api.nvim_buf_set_lines(buffer, -1, -1, false, { "" })
                end
            end
        elseif state == "END" then
            vim.api.nvim_buf_set_lines(buffer, -1, -1, false, { "", self.modes.user.prefix, "", "" })
        end
    end

    vim.api.nvim_buf_set_lines(buffer, -1, -1, false, { "", self.modes.assistant.prefix, "", "" })
    self:do_request(callback)
end

return Session
