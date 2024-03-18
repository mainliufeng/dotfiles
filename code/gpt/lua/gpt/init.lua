local config = {
    current_session_file = vim.fn.stdpath("data"):gsub("/$", "") .. "/gpt/sessions/current.md",
    default_model = "gpt-4",
    default_temperature = 0.2,
    openai_url = "https://api.openai.com/v1/chat/completions",
    openai_api_key = os.getenv("OPENAI_API_KEY"),
}

local gpt = {}

gpt.setup = function(args)
    config = vim.tbl_deep_extend("force", config, args or {})
    -- print("config in gpt.lua" .. vim.fn.json_encode(config))

    local actions = require("gpt.actions")
    local openai_client = require("gpt.openai_client")
    actions.setup(config)
    openai_client.setup(config)

    vim.api.nvim_create_user_command("GPTSessionList", function()
        vim.cmd("Oil ~/.local/share/nvim/gpt/sessions")
    end, { nargs = "?", range = false, desc = "" })

    vim.api.nvim_create_user_command("GPTSessionRun", function()
        actions.run_session()
    end, { nargs = "?", range = false, desc = "" })

    vim.api.nvim_create_user_command("GPTNewBuffer", function(params)
        actions.run_command(params, "", "newbuffer")
    end, { nargs = "?", range = true, desc = "" })

    vim.api.nvim_create_user_command("GPTReplace", function(params)
        actions.run_command(params, "", "replace")
    end, { nargs = "?", range = true, desc = "" })

end

return gpt
