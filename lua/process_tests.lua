local f = require("plenary.filetype")
local run = require("run_test")
local defs = require("definitions")

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

local function display(ac, cases, results)
    local header = "RESULTS: " .. ac .. "/" .. cases .. " AC"
    if ac == cases then
        header = header .. " 🎉🎉"
    end
    local bufnr = require("plenary.window.float").centered_with_top_win({ header }, {
        external = true,
    }).bufnr
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

function M.process(...)
    local args = { ... }
    local ft = f.detect(vim.api.nvim_buf_get_name(0))
    if defs.compile_cmd[ft] ~= nil then
        vim.fn.jobstart((vim.g[ft .. "_compile_command"] or defs.compile_cmd[ft]), {
            on_exit = function(_, exit_code, _)
                if exit_code == 0 then
                    local ac, cases, results = iterate_cases(args)
                    display(ac, cases, results)
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

function M.process_retests(...)
    local args = { ... }
    local ac, cases, results = iterate_cases(args)
    display(ac, cases, results)
end

return M
