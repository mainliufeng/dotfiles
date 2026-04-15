local M = {}

function M.run()
    local preview = require("mainliufeng.plugins.markdown")

    local cases = {
        {
            name = "markdown files still render to html",
            input = { path = "/tmp/note.md", filetype = "markdown" },
            expected = { mode = "render_markdown" },
        },
        {
            name = "saved html files open directly",
            input = { path = "/tmp/page.html", filetype = "html" },
            expected = { mode = "open_file", target = "file:///tmp/page.html" },
        },
        {
            name = "saved image files open directly",
            input = { path = "/tmp/image.png", filetype = "png" },
            expected = { mode = "open_file", target = "file:///tmp/image.png" },
        },
        {
            name = "saved non markdown files open directly",
            input = { path = "/tmp/data.txt", filetype = "text" },
            expected = { mode = "open_file", target = "file:///tmp/data.txt" },
        },
        {
            name = "unnamed non markdown buffers must be saved first",
            input = { path = "", filetype = "text" },
            expected_error = "Current buffer has no file path; save it before previewing",
        },
    }

    for _, case in ipairs(cases) do
        local ok, result = pcall(preview._resolve_preview_request, case.input)
        if case.expected_error then
            assert(not ok, case.name .. ": expected an error")
            assert(tostring(result):find(case.expected_error, 1, true), case.name .. ": unexpected error: " .. tostring(result))
        else
            assert(ok, case.name .. ": expected success, got error: " .. tostring(result))
            assert(vim.deep_equal(result, case.expected), case.name .. ": unexpected result")
        end
    end
end

return M
