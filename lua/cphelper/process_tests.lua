local f = require("plenary.filetype")
local path = require("plenary.path")
local run = require("cphelper.run_test")
local defs = require("cphelper.definitions")

local function iterate_cases(args)
    local cwd = vim.fn.getcwd()
    local ft = f.detect(vim.api.nvim_buf_get_name(0))
    local ac, cases = 0, 0
    local results = {}
    if #args == 0 then
        for _, input_file in ipairs(require("plenary.scandir").scan_dir(cwd, {
            search_pattern = "input%d+",
            depth = 1,
        })) do
            local result, status = run.run_test(
                string.sub(input_file, string.len(cwd) - string.len(input_file) + 1),
                defs.run_cmd[ft]
            )
            vim.list_extend(results, result)
            ac = ac + status -- status is 1 on correct answer, 0 otherwise
            cases = cases + 1
        end
    else
        for _, case in ipairs(args) do
            local result, status = run.run_test("input" .. case, defs.run_cmd[ft])
            vim.list_extend(results, result)
            ac = ac + status
            cases = cases + 1
        end
    end
    return ac, cases, results
end

local function display_results(ac, cases, results)
    local header = "   RESULTS: " .. ac .. "/" .. cases .. " AC"
    if ac == cases then
        header = header .. " 🎉🎉"
    end
    local contents = { "", header, "" }
    for _, line in ipairs(results) do
        table.insert(contents, line)
    end
    local bufnr = require("cphelper.helpers").display_right(contents)
    vim.api.nvim_buf_set_option(bufnr, "modifiable", false)
    vim.api.nvim_buf_set_option(bufnr, "filetype", "Results")
    local highlights = {
        ["Status: AC"] = "DiffAdd",
        ["Status: WA"] = "Error",
        ["Status: RTE"] = "Error",
        ["Case #\\d\\+"] = "DiffChange",
        ["Input:"] = "Underline",
        ["Expected output:"] = "Underline",
        ["Received output:"] = "Underline",
        ["Error:\n"] = "Underline",
    }
    for match, group in pairs(highlights) do
        vim.fn.matchadd(group, match)
    end
    vim.api.nvim_buf_set_keymap(bufnr, "n", "<esc>", "<cmd>bd<CR>", { noremap = true })
    vim.api.nvim_buf_set_keymap(bufnr, "n", "q", "<cmd>bd<CR>", { noremap = true })
end

local M = {}

function M.process(...)
    local ft = f.detect(vim.api.nvim_buf_get_name(0))
    local binary = path.new(path.new(vim.api.nvim_buf_get_name(0)):parent()):joinpath(ft .. ".out")
    pcall(binary:rm(), nil)
    if defs.compile_cmd[ft] ~= nil then
        vim.api.nvim_command("make " .. ft)
        if binary:exists() then
            M.process_retests(...)
        end
    elseif ft == "rust" then
        vim.cmd("compiler rustc")
        local rustc_args = vim.g.cph_rustc_args or defs.rustc_args
        vim.api.nvim_command("make " .. rustc_args)
        if binary:exists() then
            M.process_retests(...)
        end
    else
        M.process_retests(...)
    end
end

function M.process_retests(...)
    local args = { ... }
    local ac, cases, results = iterate_cases(args)
    display_results(ac, cases, results)
end

return M
