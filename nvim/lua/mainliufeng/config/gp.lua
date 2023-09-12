local conf = {
	openai_api_endpoint = "https://api.openai.com/v1/chat/completions",
    -- required openai api key
    openai_api_key = os.getenv("OPENAI_API_KEY"),
    -- prefix for all commands
    cmd_prefix = "Gp",

    -- directory for storing chat files
    chat_dir = vim.fn.stdpath("data"):gsub("/$", "") .. "/gp/chats",
    -- context chat file
    command_context_file = "",
    -- chat model (string with model name or table with model name and parameters)
    chat_model = { model = "gpt-3.5-turbo-16k", temperature = 0.7, top_p = 1 },
    -- chat model system prompt
    chat_system_prompt = "You are a general AI assistant.",
    -- chat user prompt prefix
    chat_user_prefix = "🗨:",
    -- chat assistant prompt prefix
    chat_assistant_prefix = "🤖:",
    -- chat topic generation prompt
    chat_topic_gen_prompt = "Summarize the topic of our conversation above"
        .. " in two or three words. Respond only with those words.",
    -- chat topic model (string with model name or table with model name and parameters)
    chat_topic_gen_model = "gpt-3.5-turbo-16k",
    -- explicitly confirm deletion of a chat file
    chat_confirm_delete = true,
    -- conceal model parameters in chat
    chat_conceal_model_params = true,
    -- local shortcuts bound to the chat buffer
    -- (be careful to choose something which will work across specified modes)
    chat_shortcut_respond = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g><C-g>" },
    chat_shortcut_delete = { modes = { "n", "i", "v", "x" }, shortcut = "<C-g>d" },

    -- command config and templates bellow are used by commands like GpRewrite, GpEnew, etc.
    -- command prompt prefix for asking user for input
    command_prompt_prefix = "🤖 ~ ",
    -- command model (string with model name or table with model name and parameters)
    command_model = { model = "gpt-3.5-turbo-16k", temperature = 0.7, top_p = 1 },
    -- command system prompt
    command_system_prompt = "You are an AI that strictly generates just the formated final code.",

    -- templates
    template_selection = "I have the following code from {{filename}}:"
        .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}",
    template_rewrite = "I have the following code from {{filename}}:"
        .. "\n\n```{{filetype}}\n{{selection}}\n```\n\n{{command}}"
        .. "\n\nRespond just with the formated final code. !!And please: No ``` code ``` blocks.",
    template_command = "{{command}}",

    -- example hook functions (see Extend functionality section in the README)
    hooks = {
        InspectPlugin = function(plugin, params)
            print(string.format("Plugin structure:\n%s", vim.inspect(plugin)))
            print(string.format("Command params:\n%s", vim.inspect(params)))
        end,

        DocString = function(gp, params)
            local template = "#使用中文编写doc\n# An elaborate, high quality docstring for the above function:\n# Writing a good docstring\n\nThis is an example of writing a really good docstring that follows a best practice for the given language. Attention is paid to detailing things like\n* parameter and return types (if applicable)\n* any errors that might be raised or returned, depending on the language\n\nI received the following code:\n\n```{{filetype}}\n{{selection}}\n```\n\nThe code with a really good docstring added is below:\n\n```{{filetype}}"
            gp.Prompt(
                params,
                gp.Target.rewrite,
                nil, -- command will run directly without any prompting for user input
                gp.config.command_model,
                template,
                gp.config.command_system_prompt
            )
        end,

        Implement = function(gp, params)
            local template = "Complete the following code written in {{filetype}} by pasting the existing code and continuing it.注释请使用中文.\n\nExisting code:\n```{{filetype}}\n{{selection}}\n```\n\n```{{filetype}}\n"
            gp.Prompt(
                params,
                gp.Target.rewrite,
                nil, -- command will run directly without any prompting for user input
                gp.config.command_model,
                template,
                gp.config.command_system_prompt
            )
        end,

        Explain = function(gp, params)
            local template = "I have the following code from {{filename}}:\n\n"
                .. "```{{filetype}}\n{{selection}}\n```\n\n"
                .. "Please respond by explaining the code above."
                .. "请使用中文回答."
            gp.Prompt(params, gp.Target.popup, nil, gp.config.command_model,
                template, gp.config.chat_system_prompt)
        end,

        UnitTests = function(gp, params)
            local template = "I have the following code from {{filename}}:\n\n"
                .. "```{{filetype}}\n{{selection}}\n```\n\n"
                .. "Please respond by writing table driven unit tests for the code above."
                .. "注释使用中文."
            gp.Prompt(params, gp.Target.enew, nil, gp.config.command_model,
                template, gp.config.command_system_prompt)
        end,
    },
}
require("gp").setup(conf)
