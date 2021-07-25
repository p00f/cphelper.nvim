local M = {}

function M.sanitize(s)
    local unwanted = { "-", " ", "#", "%.", ":", "'" }
    for _, char in pairs(unwanted) do
        local pos = string.find(s, char)
        while pos do
            s = string.sub(s, 1, pos - 1) .. string.sub(s, pos + 1)
            pos = string.find(s, char)
        end
    end
    return s
end

-- Compares two tables (list-like/map-like)
--- @param t1 table #The first table
--- @param t2 table #The second table
function M.comparetables(t1, t2)
    if #t1 ~= #t2 then
        return false
    end
    for k, v in pairs(t1) do
        if t2[k] ~= v then
            return false
        end
    end
    return true
end

-- Copied from neovim master.
-- Credits: Christian Clason and Hirokazu Hata
function M.pad(contents, opts)
    vim.validate({
        contents = { contents, "t" },
        opts = { opts, "t", true },
    })
    opts = opts or {}
    local left_padding = (" "):rep(opts.pad_left or 1)
    local right_padding = (" "):rep(opts.pad_right or 1)
    for i, line in ipairs(contents) do
        contents[i] = string.format("%s%s%s", left_padding, line:gsub("\r", ""), right_padding)
    end
    if opts.pad_top then
        for _ = 1, opts.pad_top do
            table.insert(contents, 1, "")
        end
    end
    if opts.pad_bottom then
        for _ = 1, opts.pad_bottom do
            table.insert(contents, "")
        end
    end
    return contents
end

function M.display_right(contents)
    local bufnr = vim.api.nvim_create_buf(false, true)
    local width = math.floor(vim.o.columns * 0.5)
    local height = math.floor(vim.o.lines * 0.9)
    vim.api.nvim_open_win(bufnr, true, {
        border = vim.g.cphborder or "rounded",
        style = "minimal",
        relative = "editor",
        row = math.floor(((vim.o.lines - height) / 2) - 1),
        col = math.floor(vim.o.columns - width - 1),
        width = width,
        height = height,
    })
    contents = M.pad(contents, { pad_top = 1 })
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, contents)
    return bufnr
end

return M
