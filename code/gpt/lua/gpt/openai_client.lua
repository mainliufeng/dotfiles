local curl = require("plenary.curl")

local client = {}

local config = {
    openai_url = "",
    openai_api_key = "",
}

function client.setup(user_config)
    config = vim.tbl_deep_extend("force", config, user_config or {})
end

-- 调用openai http接口
---@param session table # session, 包括model, temperature, messages
---@param callback function(string, string) # callback函数，第一个参数是content，第二个参数是state（选项"START", "CONTINUE", "ERROR", "DONE"）
function client.do_request(session, callback)
    -- Prepare the request body
    local req_body = {
        model = session.model,
        temperature = session.temperature,
        messages = session.messages,
        stream = true,
    }

    -- Prepare the request headers
    local req_headers = {}
    req_headers["Content-Type"] = "application/json"
    req_headers["Authorization"] = "Bearer " .. config.openai_api_key

    -- Convert the request body to a JSON string
    local req_body_string = vim.fn.json_encode(req_body)
    local raw_chunks = ""
    local state = "START"

    -- Wrap the callback function with vim.schedule_wrap to ensure it runs in the main thread
    callback = vim.schedule_wrap(callback)

    -- Make the POST request using plenary.curl
    curl.post(config.openai_url, {
        body = req_body_string,
        headers = req_headers,
        stream = function(error, chunk)
            if error ~= nil then
                print("Error: " .. error)
                return
            end

            local ok, json = pcall(vim.json.decode, chunk)
            if ok and json ~= nil and json.error ~= nil then
                print("Error: " .. chunk)
                return
            end

            for line in chunk:gmatch("[^\n]+") do
                local raw_json = string.gsub(line, "^data: ", "")
                if raw_json == "[DONE]" then
                    callback(raw_chunks, "END")
                else
                    ok, json = pcall(vim.json.decode, raw_json)
                    if ok and json ~= nil then
                        if json and json.choices and json.choices[1] and json.choices[1].delta and json.choices[1].delta.content then
                            callback(json.choices[1].delta.content, state)
                            raw_chunks = raw_chunks .. json.choices[1].delta.content
                            state = "CONTINUE"
                        end
                    else
                        print("Error: " .. line)
                    end
                end
            end
        end,
        on_error = function(err)
            callback(err, "ERROR")
        end,
    })
end

return client
