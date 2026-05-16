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

    local original_executable = vim.fn.executable
    vim.fn.executable = function(cmd)
        if cmd == "google-chrome-stable" or cmd == "gtk-launch" or cmd == "xdg-open" then
            return 1
        end
        return 0
    end

    local browser = preview._browser_command("file:///tmp/page.html", { sysname = "Linux" })
    vim.fn.executable = original_executable

    assert(
        vim.deep_equal(browser, { "google-chrome-stable", "--ozone-platform=x11", "file:///tmp/page.html" }),
        "preview opener should prefer a direct Linux Chrome command over desktop launchers"
    )

    vim.fn.executable = function(cmd)
        if cmd == "gtk-launch" or cmd == "xdg-open" or cmd == "gio" then
            return 1
        end
        return 0
    end

    local linux_fallback = preview._browser_command("file:///tmp/page.html", { sysname = "Linux" })
    vim.fn.executable = original_executable

    assert(
        vim.deep_equal(linux_fallback, { "xdg-open", "file:///tmp/page.html" }),
        "preview opener should fall back to the Linux system opener before gtk-launch"
    )

    vim.fn.executable = function(cmd)
        if cmd == "open" or cmd == "gtk-launch" or cmd == "xdg-open" then
            return 1
        end
        return 0
    end

    local mac_browser = preview._browser_command("file:///tmp/page.html", { sysname = "Darwin" })
    vim.fn.executable = original_executable

    assert(
        vim.deep_equal(mac_browser, { "open", "file:///tmp/page.html" }),
        "preview opener should use macOS open on Darwin"
    )
end

return M
