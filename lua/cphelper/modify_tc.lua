local path = require("plenary.path")

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
        path.new(vim.fn.getcwd() .. path.path.sep .. "input" .. case):rm()
        path.new(vim.fn.getcwd() .. path.path.sep .. "output" .. case):rm()
    end
end

return M
