local M = {}

local markdown_filetypes = {
    markdown = true,
    quarto = true,
    rmd = true,
}

local markdown_extensions = {
    markdown = true,
    md = true,
    mdown = true,
    mkd = true,
    qmd = true,
    rmd = true,
}

local function write_temp_file(lines, suffix)
    local path = vim.fn.tempname() .. suffix
    vim.fn.writefile(lines, path)
    return path
end

local function browser_command(target)
    local candidates = {
        { cmd = "gtk-launch", args = { "google-chrome.xorg", target } },
        { cmd = "google-chrome-stable", args = { target } },
        { cmd = "google-chrome", args = { target } },
        { cmd = "chromium", args = { target } },
        { cmd = "chromium-browser", args = { target } },
        { cmd = "xdg-open", args = { target } },
        { cmd = "gio", args = { "open", target } },
    }

    for _, candidate in ipairs(candidates) do
        if vim.fn.executable(candidate.cmd) == 1 then
            local argv = { candidate.cmd }
            vim.list_extend(argv, candidate.args)
            return argv
        end
    end

    return nil
end

local function preview_uri(path)
    return vim.uri_from_fname(vim.fs.normalize(path))
end

local function is_markdown_buffer(path, filetype)
    if markdown_filetypes[filetype] then
        return true
    end

    local ext = vim.fn.fnamemodify(path or "", ":e"):lower()
    return markdown_extensions[ext] == true
end

local function resolve_preview_request(opts)
    local path = opts.path or ""
    local filetype = opts.filetype or ""

    if is_markdown_buffer(path, filetype) then
        return { mode = "render_markdown" }
    end

    if path == "" then
        error("Current buffer has no file path; save it before previewing")
    end

    return {
        mode = "open_file",
        target = preview_uri(path),
    }
end

local function output_html_path()
    local output_dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "markdown-preview")
    vim.fn.mkdir(output_dir, "p")
    local filename = vim.fn.expand("%:t:r")
    if filename == "" then
        filename = "preview"
    end
    local suffix = string.sub(vim.fn.sha256(tostring(vim.loop.hrtime())), 1, 8)
    return vim.fs.joinpath(output_dir, filename .. "-" .. suffix .. ".html")
end

local function mermaid_filter_path()
    return write_temp_file({
        'function CodeBlock(block)',
        '  if block.classes[1] == "mermaid" then',
        '    return pandoc.RawBlock("html", "<div class=\\"mermaid\\">\\n" .. block.text .. "\\n</div>")',
        '  end',
        'end',
    }, ".lua")
end

local function buffer_resource_path()
    local paths = {}
    local seen = {}

    local function add(path)
        if not path or path == "" or seen[path] then
            return
        end
        seen[path] = true
        table.insert(paths, path)
    end

    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname ~= "" then
        add(vim.fs.dirname(bufname))
    end

    add(vim.fn.getcwd())

    return table.concat(paths, ":")
end

local function current_buffer_dir()
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname == "" then
        return nil
    end
    return vim.fs.dirname(bufname)
end

local function absolutize_local_image_links(lines)
    local base_dir = current_buffer_dir()
    if not base_dir then
        return lines
    end

    local function normalize_target(target)
        local path = vim.trim(target)
        if path == "" then
            return target
        end

        if path:match("^[a-zA-Z][a-zA-Z0-9+.-]*://") or path:match("^data:") then
            return target
        end

        local inner = path:match("^<(.+)>$")
        if inner then
            path = inner
        end

        if path:match("^#") then
            return target
        end

        local clean_path = path:match('^([^%s]+)') or path
        if not clean_path:match("^%.?%.?/") and not clean_path:match("^/") then
            return target
        end

        local absolute = clean_path
        if not clean_path:match("^/") then
            absolute = vim.fs.normalize(vim.fs.joinpath(base_dir, clean_path))
        end

        local uri = vim.uri_from_fname(absolute)
        local suffix = path:sub(#clean_path + 1)
        if inner then
            return "<" .. uri .. suffix .. ">"
        end
        return uri .. suffix
    end

    local out = {}
    for _, line in ipairs(lines) do
        local rewritten = line:gsub("!%[([^%]]-)%]%(([^%)]+)%)", function(alt, target)
            return string.format("![%s](%s)", alt, normalize_target(target))
        end)
        table.insert(out, rewritten)
    end
    return out
end

local function collect_local_image_files(lines)
    local base_dir = current_buffer_dir()
    if not base_dir then
        return {}
    end

    local files = {}
    local seen = {}

    local function add_target(target)
        local path = vim.trim(target)
        if path == "" then
            return
        end
        if path:match("^[a-zA-Z][a-zA-Z0-9+.-]*://") or path:match("^data:") or path:match("^#") then
            return
        end

        local inner = path:match("^<(.+)>$")
        if inner then
            path = inner
        end

        local clean_path = path:match('^([^%s]+)') or path
        if not clean_path:match("^%.?%.?/") and not clean_path:match("^/") then
            return
        end

        local absolute = clean_path
        if not clean_path:match("^/") then
            absolute = vim.fs.normalize(vim.fs.joinpath(base_dir, clean_path))
        end

        if vim.fn.filereadable(absolute) == 1 and not seen[absolute] then
            seen[absolute] = true
            table.insert(files, absolute)
        end
    end

    for _, line in ipairs(lines) do
        for target in line:gmatch("!%[[^%]]-%]%(([^%)]+)%)") do
            add_target(target)
        end
    end

    return files
end

local function copy_local_images_to_output_dir(image_files, html_path)
    if not image_files or #image_files == 0 then
        return
    end

    local output_dir = vim.fs.dirname(html_path)
    for _, image_path in ipairs(image_files) do
        local dest_path = vim.fs.joinpath(output_dir, vim.fs.basename(image_path))
        if vim.fn.filereadable(dest_path) ~= 1 then
            vim.fn.writefile(vim.fn.readfile(image_path, "b"), dest_path, "b")
        end
    end
end

local function html_unescape(text)
    return text
        :gsub("&lt;", "<")
        :gsub("&gt;", ">")
        :gsub("&quot;", '"')
        :gsub("&#39;", "'")
        :gsub("&amp;", "&")
end

local function normalize_mermaid_blocks(html_path)
    local lines = vim.fn.readfile(html_path)
    local html = table.concat(lines, "\n")
    html = html:gsub('(<div class="mermaid">%s*\n)(.-)(\n</div>)', function(prefix, content, suffix)
        return prefix .. html_unescape(content) .. suffix
    end)
    vim.fn.writefile(vim.split(html, "\n", { plain = true }), html_path)
end

local function rewrite_html_local_image_paths(html_path)
    local base_dir = current_buffer_dir()
    if not base_dir then
        return
    end

    local lines = vim.fn.readfile(html_path)
    local html = table.concat(lines, "\n")
    html = html:gsub('src="([^"]+)"', function(src)
        if src:match("^[a-zA-Z][a-zA-Z0-9+.-]*://") or src:match("^data:") then
            return string.format('src="%s"', src)
        end
        if not src:match("^%.?%.?/") then
            return string.format('src="%s"', src)
        end

        local absolute = src
        if not src:match("^/") then
            absolute = vim.fs.normalize(vim.fs.joinpath(base_dir, src))
        end
        return string.format('src="%s"', vim.uri_from_fname(absolute))
    end)
    vim.fn.writefile(vim.split(html, "\n", { plain = true }), html_path)
end

local function render_markdown_to_html()
    if vim.fn.executable("pandoc") ~= 1 then
        error("pandoc is not installed")
    end

    local markdown_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local local_image_files = collect_local_image_files(markdown_lines)
    markdown_lines = absolutize_local_image_links(markdown_lines)
    local markdown_path = write_temp_file(markdown_lines, ".md")
    local html_path = output_html_path()
    local filter_path = mermaid_filter_path()
    local header_path = write_temp_file({
        '<script type="module">',
        '  import mermaid from "https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs";',
        '  mermaid.initialize({ startOnLoad: false });',
        '',
        '  const clamp = (value, min, max) => Math.min(max, Math.max(min, value));',
        '',
        '  function getSvgSize(svg) {',
        '    const viewBox = svg.viewBox && svg.viewBox.baseVal;',
        '    if (viewBox && viewBox.width > 0 && viewBox.height > 0) {',
        '      return { width: viewBox.width, height: viewBox.height };',
        '    }',
        '',
        '    const width = parseFloat(svg.getAttribute("width")) || svg.getBoundingClientRect().width || 1;',
        '    const height = parseFloat(svg.getAttribute("height")) || svg.getBoundingClientRect().height || 1;',
        '    return { width, height };',
        '  }',
        '',
        '  function applyScale(diagram) {',
        '    const { svg, stage, state } = diagram;',
        '    stage.style.width = `${state.baseWidth * state.scale}px`;',
        '    stage.style.height = `${state.baseHeight * state.scale}px`;',
        '    svg.style.transform = `scale(${state.scale})`;',
        '  }',
        '',
        '  function setScale(diagram, nextScale, anchorX, anchorY) {',
        '    const { viewport, state } = diagram;',
        '    const oldScale = state.scale;',
        '    const clampedScale = clamp(nextScale, 0.2, 6);',
        '    if (Math.abs(clampedScale - oldScale) < 0.001) {',
        '      return;',
        '    }',
        '',
        '    const rect = viewport.getBoundingClientRect();',
        '    const offsetX = anchorX - rect.left;',
        '    const offsetY = anchorY - rect.top;',
        '    const diagramX = (viewport.scrollLeft + offsetX) / oldScale;',
        '    const diagramY = (viewport.scrollTop + offsetY) / oldScale;',
        '',
        '    state.scale = clampedScale;',
        '    applyScale(diagram);',
        '',
        '    viewport.scrollLeft = diagramX * state.scale - offsetX;',
        '    viewport.scrollTop = diagramY * state.scale - offsetY;',
        '  }',
        '',
        '  function enhanceMermaidDiagram(block) {',
        '    if (block.dataset.interactiveReady === "true") {',
        '      return;',
        '    }',
        '',
        '    const svg = block.querySelector("svg");',
        '    if (!svg) {',
        '      return;',
        '    }',
        '',
        '    const { width, height } = getSvgSize(svg);',
        '    const viewport = document.createElement("div");',
        '    viewport.className = "mermaid-viewport";',
        '',
        '    const stage = document.createElement("div");',
        '    stage.className = "mermaid-stage";',
        '',
        '    block.classList.add("mermaid-block");',
        '    svg.style.display = "block";',
        '    svg.style.width = `${width}px`;',
        '    svg.style.height = `${height}px`;',
        '    svg.style.maxWidth = "none";',
        '    svg.style.transformOrigin = "top left";',
        '',
        '    block.replaceChildren(viewport);',
        '    viewport.appendChild(stage);',
        '    stage.appendChild(svg);',
        '',
        '    const diagram = {',
        '      viewport,',
        '      stage,',
        '      svg,',
        '      state: {',
        '        baseWidth: width,',
        '        baseHeight: height,',
        '        scale: 1,',
        '      },',
        '    };',
        '',
        '    applyScale(diagram);',
        '    block.dataset.interactiveReady = "true";',
        '',
        '    viewport.addEventListener("wheel", (event) => {',
        '      if (!event.ctrlKey) {',
        '        return;',
        '      }',
        '',
        '      event.preventDefault();',
        '      const zoomFactor = Math.exp(-event.deltaY * 0.01);',
        '      setScale(diagram, diagram.state.scale * zoomFactor, event.clientX, event.clientY);',
        '    }, { passive: false });',
        '  }',
        '',
        '  async function renderMermaid() {',
        '    await mermaid.run({ querySelector: ".mermaid" });',
        '    document.querySelectorAll(".mermaid").forEach(enhanceMermaidDiagram);',
        '  }',
        '',
        '  if (document.readyState === "loading") {',
        '    window.addEventListener("DOMContentLoaded", renderMermaid, { once: true });',
        '  } else {',
        '    renderMermaid();',
        '  }',
        "</script>",
        "<style>",
        "  body { max-width: 960px; margin: 40px auto; padding: 0 24px; font-family: sans-serif; line-height: 1.7; }",
        "  pre { overflow-x: auto; padding: 12px; background: #f5f5f5; border-radius: 8px; }",
        "  code { font-family: monospace; }",
        "  img { max-width: 100%; }",
        "  .mermaid-block { margin: 20px 0; background: #fff; border: 1px solid #d7dee7; border-radius: 12px; }",
        "  .mermaid-viewport { overflow: auto; max-width: 100%; max-height: 75vh; padding: 16px; overscroll-behavior: contain; }",
        "  .mermaid-stage { position: relative; }",
        "  .mermaid-stage > svg { display: block; }",
        "</style>",
    }, ".html")

    vim.fn.system({
        "pandoc",
        markdown_path,
        "--from=markdown",
        "--to=html5",
        "--standalone",
        "--embed-resources",
        "--resource-path",
        buffer_resource_path(),
        "--lua-filter",
        filter_path,
        "--include-in-header",
        header_path,
        "--metadata",
        "title=" .. vim.fn.expand("%:t"),
        "--output",
        html_path,
    })

    if vim.v.shell_error ~= 0 then
        error("pandoc failed: " .. vim.v.shell_error)
    end

    normalize_mermaid_blocks(html_path)
    rewrite_html_local_image_paths(html_path)
    copy_local_images_to_output_dir(local_image_files, html_path)

    return html_path
end

local function notify_path(html_path)
    vim.g.markdown_preview_last_html = html_path
    vim.b.markdown_preview_last_html = html_path
    vim.notify("Markdown HTML: " .. html_path, vim.log.levels.INFO, { title = "Markdown Preview" })
end

local function open_in_browser(target)
    local browser = browser_command(target)
    if not browser then
        error("No browser command found")
    end

    vim.fn.jobstart(browser, { detach = true })
end

local function current_preview_request()
    return resolve_preview_request({
        path = vim.api.nvim_buf_get_name(0),
        filetype = vim.bo.filetype,
    })
end

function M.setup()
    vim.api.nvim_create_user_command("MarkdownHTML", function()
        local html_path = render_markdown_to_html()
        notify_path(html_path)
    end, { desc = "Render current markdown buffer to HTML" })

    vim.api.nvim_create_user_command("PreviewOpen", function()
        local request = current_preview_request()
        if request.mode == "render_markdown" then
            local html_path = render_markdown_to_html()
            open_in_browser(preview_uri(html_path))
            notify_path(html_path)
            return
        end

        open_in_browser(request.target)
        vim.notify("Opened in browser: " .. vim.api.nvim_buf_get_name(0), vim.log.levels.INFO, { title = "Preview" })
    end, { desc = "Preview current buffer in browser" })

    vim.api.nvim_create_user_command("MarkdownOpen", function()
        vim.cmd("PreviewOpen")
    end, { desc = "Preview current buffer in browser" })
end

M._resolve_preview_request = resolve_preview_request
M._browser_command = browser_command

return M
