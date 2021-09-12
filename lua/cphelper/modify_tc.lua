local p = require("plenary.path")

local M = {}

-- Edit a test case
--- @param case number#Test case no.
function M.edittc(case)
    vim.cmd("tabe output" .. case)
    vim.cmd("vsplit input" .. case)
end

-- Deletes test cases
--- @vararg number #Test case nos.
function M.deletetc(...)
    local cases = { ... }
    for _, case in pairs(cases) do
        p.new(vim.fn.getcwd() .. p.path.sep .. "input" .. case):rm()
        p.new(vim.fn.getcwd() .. p.path.sep .. "output" .. case):rm()
    end
end

return M
