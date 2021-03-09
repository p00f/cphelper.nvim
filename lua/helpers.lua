local M = {}

function M.sanitize(s)
    local unwanted = {"-", " ", "#", "%."}
    for _, char in pairs(unwanted) do
        local pos = string.find(s, char)
        while pos do
            s = string.sub(s, 1, pos - 1) .. string.sub(s, pos + 1)
            pos = string.find(s, char)
        end
    end
    return s
end

function M.vglobal_or_default(var, default)
    local exists, value = pcall(vim.api.nvim_get_var, var)
    if exists then
        return value
    else
        return default
    end
end

function M.read_string(path)
    local file = io.open(path)
    if not file then return nil end
    local content = file:read "*a"
    file:close()
    return content
end

function M.read_lines(path)
    local lines = {}
    for line in io.lines(path) do table.insert(lines, line) end
    return lines
end

function M.split_lines(s)
    local lines = {}
    for ss in string.gmatch(s, "[^\r\n]+") do table.insert(lines, ss) end
    return lines
end

-- Copied from neovim master.
-- Credits: Christian Clason and Hirokazu Hata
function M.pad(contents, opts)
    vim.validate {contents = {contents, 't'}, opts = {opts, 't', true}}
    opts = opts or {}
    local left_padding = (" "):rep(opts.pad_left or 1)
    local right_padding = (" "):rep(opts.pad_right or 1)
    for i, line in ipairs(contents) do
        contents[i] = string.format('%s%s%s', left_padding, line:gsub("\r", ""),
                                    right_padding)
    end
    if opts.pad_top then
        for _ = 1, opts.pad_top do table.insert(contents, 1, "") end
    end
    if opts.pad_bottom then
        for _ = 1, opts.pad_bottom do table.insert(contents, "") end
    end
    return contents
end

return M
