local buffers = {}

function buffers.delete_line(buffer, line)
	vim.api.nvim_buf_set_lines(buffer, line-1, line, false, {})
end

function buffers.delete_lines(buffer, start_line, end_line)
	vim.api.nvim_buf_set_lines(buffer, start_line-1, end_line, false, {})
end

function buffers.replace_line(buffer, line, content)
	vim.api.nvim_buf_set_lines(buffer, line-1, line, false, {content})
end

-- 再line后面插入行
function buffers.insert_line(buffer, line, content)
	vim.api.nvim_buf_set_lines(buffer, line, line, false, {content})
end

function buffers.create_stream_insert_handler(buffer, line)
    local first = true
    local content = ""
    return function(chunk)
        -- 跳过空
        if not chunk or chunk == "" then
            return
        end

        -- 首次先插入空行
        if first then
		    vim.cmd("undojoin")
            buffers.insert_line(buffer, line, "")
            line = line + 1
            first = false
        end

        content = content .. chunk
        local content_lines = vim.split(content, "\n", {})
        -- 如果content中第一行不是空，替换单前行
        if content_lines[1] ~= "" then
		    vim.cmd("undojoin")
            buffers.replace_line(buffer, line, content_lines[1])
        end

        -- 如果content有换行，向下插入行
        if #content_lines > 1 then
            for i, content_line in ipairs(content_lines) do
                if i > 1 then
		            vim.cmd("undojoin")
                    buffers.insert_line(buffer, line, content_line)
                    line = line + 1
                    content = content_line
                end
            end
        end
    end
end

return buffers
