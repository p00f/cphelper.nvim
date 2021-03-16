local s = require("plenary.scandir")
local f = require("plenary.filetype")
local h = require("helpers")
local run = require("run_test")
local fw = require("plenary.window.float")

local def_compile_cmd = {
        c = "gcc solution.c -o c.out",
        cpp = "g++ solution.cpp -o cpp.out",
}

local run_cmd = {
        c = "./c.out",
        cpp = "./cpp.out",
        lua = "lua solution.lua",
        python = "python solution.py",
}

local function iterate_cases(args)
        local cwd = vim.fn.getcwd()
        local ft = f.detect(vim.api.nvim_buf_get_name(0))
        local ac, cases = 0, 0
        local results = {}
        if #args == 0 then
                for _, input_file in ipairs(s.scan_dir(cwd, {
                        search_pattern = "input%d+",
                        depth = 1,
                })) do
                        local result, status = run.run_test(
                                string.sub(input_file, string.len(cwd) - string.len(input_file) + 1),
                                run_cmd[ft]
                        )
                        vim.list_extend(results, result)
                        ac = ac + status -- status is 1 on correct answer, 0 otherwise
                        cases = cases + 1
                end
        else
                for _, case in ipairs(args) do
                        local result, status = run.run_test("input" .. case, run_cmd[ft])
                        vim.list_extend(results, result)
                        ac = ac + status
                        cases = cases + 1
                end
        end
        return ac, cases, results
end

local function display(ac, cases, results)
        local header = "RESULTS: " .. ac .. "/" .. cases .. " AC"
        if ac == cases then
                header = header .. " 🎉🎉"
        end
        local bufnr = fw.centered_with_top_win({ header }).bufnr
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, results)
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
end

local M = {}

function M.wrapper(...)
        local args = { ... }
        local ft = f.detect(vim.api.nvim_buf_get_name(0))
        if def_compile_cmd[ft] ~= nil then
                vim.fn.jobstart(
                        h.vglobal_or_default(ft .. "_compile_command", def_compile_cmd[ft]),
                        {
                                on_exit = function(_, exit_code, _)
                                        if exit_code == 0 then
                                                local ac, cases, results = iterate_cases(args)
                                                display(ac, cases, results)
                                        end
                                end,
                                on_stderr = function(_, data, _)
                                        local err_msg = ""
                                        for _, line in ipairs(data) do
                                                err_msg = err_msg .. line .. "\n"
                                        end
                                        vim.api.nvim_err_write(err_msg)
                                end,
                        }
                )
        else
                M.retest_wrapper(...)
        end
end

function M.retest_wrapper(...)
        local args = { ... }
        local ac, cases, results = iterate_cases(args)
        display(ac, cases, results)
end

return M
