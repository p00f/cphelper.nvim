local filetype = require("plenary.filetype")
local run = require("cphelper.run_test")
local def = require("cphelper.definitions")

--- Runs multiple test cases by calling `"cphelper.run_test".run_test()` on a binary
---@param case_numbers table #List of case numbers
---@return integer #Number of cases passed
---@return integer #Total number of cases
---@return table #Result to be displayed (list of lines)
local function iterate_cases(case_numbers)
    local cwd = vim.fn.getcwd()
    local ft = filetype.detect(vim.api.nvim_buf_get_name(0))
    local ac, cases = 0, 0
    local results = {}
    if #case_numbers == 0 then
        for _, input_file in ipairs(require("plenary.scandir").scan_dir(cwd, {
            search_pattern = "input%d+",
            depth = 1,
        })) do
            local result, status = run.run_test(
                string.sub(input_file, string.len(cwd) - string.len(input_file) + 1),
                def.run_cmd[ft]
            )
            vim.list_extend(results, result)
            ac = ac + status -- status is 1 on correct answer, 0 otherwise
            cases = cases + 1
        end
    else
        for _, case in ipairs(case_numbers) do
            local result, status = run.run_test("input" .. case, def.run_cmd[ft])
            vim.list_extend(results, result)
            ac = ac + status
            cases = cases + 1
        end
    end
    return ac, cases, results
end

--- Displays results
---@param ac number #No. of cases passed
---@param cases number #Total no. of cases
---@param results table #Result to be displayed (list of lines)
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

-- Compile and test
--- @vararg number #Case numbers to test. If not provided, then all cases are tested
function M.process(...)
    local args = { ... }
    local ft = filetype.detect(vim.api.nvim_buf_get_name(0))
    if def.compile_cmd[ft] ~= nil then
        vim.fn.jobstart((vim.g[ft .. "_compile_command"] or def.compile_cmd[ft]), {
            on_exit = function(_, exit_code, _)
                if exit_code == 0 then
                    local ac, cases, results = iterate_cases(args)
                    display_results(ac, cases, results)
                end
            end,
            on_stderr = function(_, data, _)
                local err_msg = table.concat(data, "\n")
                vim.api.nvim_err_write(err_msg)
            end,
        })
    else
        M.process_retests(...)
    end
end

-- Retest without compiling
--- @vararg number #Test case nos.
function M.process_retests(...)
    local args = { ... }
    local ac, cases, results = iterate_cases(args)
    display_results(ac, cases, results)
end

return M
