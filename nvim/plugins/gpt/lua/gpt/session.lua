local client = require("gpt.openai_client")

-- 解析session文件的模式
local Modes = {
    MODEL = {role = "", prefix =  "# Model"},
    SYSTEM = {role = "system", prefix =  "# System"},
    USER = {role = "user", prefix =  "# User"},
    ASSISTANT = {role = "assistant", prefix =  "# Assistant"},
}

local function prefix_to_mode(prefix)
    for _, mode in pairs(Modes) do
        if mode.prefix == prefix then
            return mode
        end
    end
end

local function role_to_mode(role)
    for _, mode in pairs(Modes) do
        if mode.role == role then
            return mode
        end
    end
end

local Session = {
    Modes = Modes,
}
Session.__index = Session

function Session:new(model, temperature, messages)
    self = setmetatable({}, Session)
    self.model = model
    self.temperature = temperature
    self.messages = messages or {}
    return self
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
    self = setmetatable({}, Session)
    self.messages = {}

	local content = ""
    local mode

    local parse_content = function()
        if mode ~= nil then
            if mode == Modes.MODEL then
                local model_lines = vim.split(content, "\n", {})
	            for _, model_line in ipairs(model_lines) do
                    local ok, json = pcall(vim.json.decode, model_line)
                    if ok and json ~= nil then
                        if json.model ~= nil then
                            self.model = json.model
                        end
                        if json.temperature ~= nil then
                            self.temperature = json.temperature
                        end
                    end
                end
            elseif mode == Modes.SYSTEM then
                self:append_message(Modes.SYSTEM.role, content)
            elseif mode == Modes.USER then
                self:append_message(Modes.USER.role, content)
            elseif mode == Modes.ASSISTANT then
                self:append_message(Modes.ASSISTANT.role, content)
            end
        end

    end

	for _, line in ipairs(lines) do
        local prefix = line:match("^(# %w+)")
        local maybe_mode = prefix_to_mode(prefix)
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

    return self
end

function Session:to_buf(buffer)
    vim.api.nvim_buf_set_lines(buffer, 0, -1, false, self:to_lines())
end

function Session:to_lines()
    local lines = {
        Session.Modes.MODEL.prefix,
        "",
        vim.json.encode({model = self.model, temperature = self.temperature}),
        "",
    }

    for _, message in ipairs(self.messages) do
        if message.content ~= nil then
            local content = message.content:gsub("^%s*(.-)%s*$","%1")

            if content ~= "" then
                table.insert(lines, role_to_mode(message.role).prefix)
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

function Session:do_request(callback)
    local length = #self.messages
    if length == 0 then
        return
    end

    local last_message = self.messages[length]
    if last_message.role == Modes.ASSISTANT.role then
        return
    end

    client.do_request(self, function(text, state)
        callback(text, state)
        if state == "END" then
            self:append_message(Modes.ASSISTANT.role, text)
        elseif state == "ERROR" then
            print(text)
        end
    end)
end

return Session
