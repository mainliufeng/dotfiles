local M = {}

local function write_temp_file(lines, suffix)
    local path = vim.fn.tempname() .. suffix
    vim.fn.writefile(lines, path)
    return path
end

local function browser_command()
    local candidates = {
        "google-chrome-unstable",
        "google-chrome",
        "chromium",
        "chromium-browser",
        "xdg-open",
    }

    for _, cmd in ipairs(candidates) do
        if vim.fn.executable(cmd) == 1 then
            return cmd
        end
    end

    return nil
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

local function render_markdown_to_html()
    if vim.fn.executable("pandoc") ~= 1 then
        error("pandoc is not installed")
    end

    local markdown_lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
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

    return html_path
end

local function notify_path(html_path)
    vim.g.markdown_preview_last_html = html_path
    vim.b.markdown_preview_last_html = html_path
    vim.notify("Markdown HTML: " .. html_path, vim.log.levels.INFO, { title = "Markdown Preview" })
end

function M.setup()
    vim.api.nvim_create_user_command("MarkdownHTML", function()
        local html_path = render_markdown_to_html()
        notify_path(html_path)
    end, { desc = "Render current markdown buffer to HTML" })

    vim.api.nvim_create_user_command("MarkdownOpen", function()
        local html_path = render_markdown_to_html()
        local browser = browser_command()
        if not browser then
            error("No browser command found")
        end

        vim.fn.jobstart({ browser, vim.uri_from_fname(html_path) }, { detach = true })
        notify_path(html_path)
    end, { desc = "Render current markdown buffer to HTML and open it in browser" })
end

return M
