local config = {
    current_session_file = vim.fn.stdpath("data"):gsub("/$", "") .. "/gpt/sessions/current.md",
    default_model = "gpt-3.5-turbo-0301",
    default_temperature = 0.2,
    openai = {
        url = "https://api.openai.com/v1/chat/completions",
        api_key = os.getenv("OPENAI_API_KEY"),
    },
}

local M = {}
M.config = config

M.setup = function(args)
    M.config = vim.tbl_deep_extend("force", M.config, args or {})

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

return M
