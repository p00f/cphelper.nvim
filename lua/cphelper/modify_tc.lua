local p = require("plenary.path")

local M = {}

function M.edittc(case) -- receives an integer
    vim.cmd("tabe output" .. case)
    vim.cmd("vsplit input" .. case)
end

function M.deletetc(...) -- receives integer(s)
    local cases = { ... }
    for _, case in pairs(cases) do
        p.new(vim.fn.getcwd() .. p.path.sep .. "input" .. case):rm()
        p.new(vim.fn.getcwd() .. p.path.sep .. "output" .. case):rm()
    end
end

return M
