local M = {}
local api = vim.api

-- Strips out special characters from a string
--- @param s string #The string to sanitize
--- @return string #The sanitized string
function M.sanitize(s)
    local copy = s
    local unwanted = { "-", " ", "#", "%.", ":", "'", "+", "%%" }
    for _, char in pairs(unwanted) do
        local pos = string.find(copy, char)
        while pos do
            copy = string.sub(copy, 1, pos - 1) .. string.sub(copy, pos + 1)
            pos = string.find(copy, char)
        end
    end
    return copy
end

-- Compares two lists of strings
--- @param t1 table #The first table
--- @param t2 table #The second table
--- @return string #
function M.compare_str_list(t1, t2)
    local compare = function(str1, str2)
        if str1 == str2 then
            return "yes"
        elseif str1:gsub("%s*$", "") == str2:gsub("%s*$", "") then
            return "trailing"
        else
            return "no"
        end
    end

    if #t1 ~= #t2 then
        return "no"
    end

    local trailing_match = false
    for k, _ in pairs(t1) do
        local matches = compare(t1[k], t2[k])
        if matches == "no" then
            return "no"
        elseif matches == "trailing" then
            trailing_match = true
        end
    end

    if trailing_match then
        return "trailing"
    else
        return "yes"
    end
end

--- Pads a list of lines with spaces
--- Copied from neovim master.
--- Credits: Christian Clason and Hirokazu Hata
--- @param contents table
--- @param opts table
local function pad(contents, opts)
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

-- Display the results in a floating window on the right side
--- @param contents table #List of lines to display
--- @return number #bufnr of the created window
function M.display_right(contents)
    local bufnr = api.nvim_create_buf(false, true)
    local width = 0
    for _, value in pairs(contents) do
        width = math.max(width, string.len(value))
    end
    width = width + 5
    local height = math.floor(vim.o.lines * 0.9)
    if not vim.g.cph_vsplit then
        api.nvim_open_win(bufnr, true, {
            border = vim.g.cphborder or "rounded",
            style = "minimal",
            relative = "editor",
            row = math.floor(((vim.o.lines - height) / 2) - 1),
            col = math.floor(vim.o.columns - width - 1),
            width = width,
            height = height,
        })
    else
        vim.cmd("vsplit")
        api.nvim_win_set_buf(0, bufnr)
        api.nvim_win_set_width(0, width)
        api.nvim_win_set_option(0, "number", false)
        api.nvim_win_set_option(0, "relativenumber", false)
        api.nvim_win_set_option(0, "cursorline", false)
        api.nvim_win_set_option(0, "cursorcolumn", false)
        api.nvim_win_set_option(0, "spell", false)
        api.nvim_win_set_option(0, "list", false)
        api.nvim_win_set_option(0, "signcolumn", "auto")
    end
    contents = pad(contents, { pad_top = 1 })
    api.nvim_win_set_option(0, "foldmethod", "indent")
    api.nvim_buf_set_lines(bufnr, 0, -1, true, contents)
    api.nvim_buf_set_option(bufnr, "shiftwidth", 2)
    return bufnr
end

return M
