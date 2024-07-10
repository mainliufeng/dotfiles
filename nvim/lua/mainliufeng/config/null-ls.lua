-- require("null-ls").setup({
--     debug = true,
--     sources = {
--         require("null-ls").builtins.diagnostics.golangci_lint,
--         require("null-ls").builtins.formatting.stylua,
--         require("null-ls").builtins.diagnostics.eslint,
--         require("null-ls").builtins.completion.spell,
--     },
-- })

local null_ls = require("null-ls")

local golangci_lint = {
    method = null_ls.methods.DIAGNOSTICS,
    filetypes = { "go" },
    generator = null_ls.generator({
        command = "golangci-lint",
        to_stdin = true,
        from_stderr = false,
        args = {
            "run",
            "--tests=false",
            "--enable=bodyclose",
            "--enable=gosec",
            "--enable=dupl",
            "--enable=gocritic",
            "--enable=gocyclo",
            "--enable=goconst",
            "--enable=govet",
            "--enable=misspell",
            "--out-format",
            "json",
            "$DIRNAME",
            "--path-prefix",
            "$ROOT",
        },
        format = "json",
        check_exit_code = function(code)
            return code <= 2
        end,
        on_output = function(params)
            local diags = {}
            for _, d in ipairs(params.output.Issues) do
                if d.Pos.Filename == params.bufname then
                    table.insert(diags, {
                        row = d.Pos.Line,
                        col = d.Pos.Column,
                        message = d.Text,
                    })
                end
            end
            return diags
        end,
    }),
}
-- add to other sources or register individually
null_ls.register(golangci_lint)

require("null-ls").setup({
    debug = true,
    sources = {
        golangci_lint,
        require("null-ls").builtins.formatting.gofmt,
        require("null-ls").builtins.formatting.stylua,
        require("null-ls").builtins.diagnostics.eslint,
        require("null-ls").builtins.completion.spell,
    },
})


-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup {
--   { exe = "golangci_lint", filetypes = { "go" }, },
-- }
