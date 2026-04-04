local run = require("cphelper.run_test")
local def = require("cphelper.definitions")

--- Pad a list of lines with spaces
--- Copied from neovim master.
--- Credits: Christian Clason and Hirokazu Hata
--- @param contents table
--- @param opts table?
local function pad(contents, opts)
    vim.validate("contents", contents, "table")
    vim.validate("opts", opts, "table", true)
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

--- Display the results in a floating window on the right side
--- @param contents table List of lines to display
--- @return integer # bufnr of the created window
local function display_right(contents)
    local api = vim.api
    local bufnr = api.nvim_create_buf(false, true)
    local width = 0
    for _, value in pairs(contents) do
        width = math.max(width, string.len(value))
    end
    width = width + 5
    local height = math.floor(vim.o.lines * 0.9)
    if not vim.g["cph#vsplit"] then
        api.nvim_open_win(bufnr, true, {
            border = vim.g["cph#border"] or "rounded",
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
        api.nvim_set_option_value("number", false, { win = 0 })
        api.nvim_set_option_value("relativenumber", false, { win = 0 })
        api.nvim_set_option_value("cursorline", false, { win = 0 })
        api.nvim_set_option_value("cursorcolumn", false, { win = 0 })
        api.nvim_set_option_value("spell", false, { win = 0 })
        api.nvim_set_option_value("list", false, { win = 0 })
        api.nvim_set_option_value("signcolumn", "auto", { win = 0 })
    end
    contents = pad(contents, { pad_top = 1 })
    api.nvim_set_option_value("foldmethod", "indent", { win = 0 })
    api.nvim_buf_set_lines(bufnr, 0, -1, true, contents)
    api.nvim_set_option_value("shiftwidth", 2, { buf = bufnr })
    return bufnr
end

--- Run multiple test cases by calling `"cphelper.run_test".run_test()` on a binary
---@param case_numbers table #list of case numbers
---@return integer #number of cases passed
---@return integer #total number of cases
---@return table #result to be displayed (list of lines)
local function iterate_cases(case_numbers)
    local cwd = vim.uv.cwd()
    local ft = vim.filetype.match({ filename = vim.api.nvim_buf_get_name(0) })
    local ac, cases = 0, 0
    local display = {}
    if #case_numbers == 0 then
        for _, input_file in ipairs(vim.fn.glob(cwd .. "/input*", false, true)) do
            local num = input_file:match("input(%d+)$")
            if num then
                local case_display, success = run.run_test(num, def.run_cmd[ft])
                vim.list_extend(display, case_display)
                ac = ac + success -- status is 1 on correct answer, 0 otherwise
                cases = cases + 1
            end
        end
    else
        for _, case in ipairs(case_numbers) do
            local case_display, success = run.run_test(case, def.run_cmd[ft])
            vim.list_extend(display, case_display)
            ac = ac + success
            cases = cases + 1
        end
    end
    return ac, cases, display
end

--- Display results
---@param ac integer #no. of cases passed
---@param cases integer #total no. of cases
---@param display table #result to be displayed (list of lines)
local function display_results(ac, cases, display)
    local header = "   RESULTS: " .. ac .. "/" .. cases .. " AC"
    if ac == cases then
        header = header .. " 🎉🎉"
    end
    local contents = { "", header, "" }
    for _, line in ipairs(display) do
        table.insert(contents, line)
    end
    local bufnr = display_right(contents)
    vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
    vim.api.nvim_set_option_value("filetype", "Results", { buf = bufnr })
    local highlights = {
        ["Status: AC"] = "DiffAdd",
        ["Status: WA"] = "Error",
        ["Status: RTE"] = "Error",
        ["Case #\\d\\+"] = "DiffChange",
        ["Input:"] = "CphUnderline",
        ["Expected output:"] = "CphUnderline",
        ["Received output:"] = "CphUnderline",
        ["Error:\n"] = "CphUnderline",
    }
    for match, group in pairs(highlights) do
        vim.fn.matchadd(group, match)
    end
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<esc>", "<cmd>bd<CR>", { noremap = true })
    vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<cmd>bd<CR>", { noremap = true })
end

local M = {}

--- Compile and test
--- @param args string[] #case numbers to test. If not provided, then all cases are tested
function M.process(args)
    local ft = vim.filetype.match({ filename = vim.api.nvim_buf_get_name(0) })
    if def.compile_cmd[ft] ~= nil then
        vim.system(
            (vim.g["cph#" .. ft .. "#compile_command"] or def.compile_cmd[ft]),
            {},
            function(out)
                if out.stderr then
                    vim.schedule(function()
                        vim.api.nvim_echo({ { out.stderr } }, true, { err = true })
                    end)
                end
                if out.code == 0 then
                    vim.schedule(function()
                        local ac, cases, results = iterate_cases(args)
                        display_results(ac, cases, results)
                    end)
                end
            end
        )
    else
        M.process_retests(args)
    end
end

--- Retest without compiling
--- @param args string[] #case numbers to test. If not provided, then all cases are tested
function M.process_retests(args)
    local ac, cases, display = iterate_cases(args)
    display_results(ac, cases, display)
end

return M
