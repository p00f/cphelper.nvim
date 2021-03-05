local p = require "plenary.path"
local s = require "plenary.scandir"
local M = {}

function M.wrapper(...)
  local cwd = p.new(vim.fn.getcwd())
  if ... == nil then
    for i in cwd:iter() do
      print("1")
    end
 else
    for _, case in pairs(...) do M.test(case) end
 end
end
function M.test(case)
  print(case)
end
return M
