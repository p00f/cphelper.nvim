local p = require "plenary.path"
local s = require "plenary.scandir"
local M = {}

function M.wrapper(...)
  local args = {...}
  local cwd = vim.fn.getcwd()
  if #args == 0 then
    for _, input_file in ipairs(s.scan_dir(cwd, {
      search_pattern = "input%d+",
      depth = 1
    })) do
      M.test(
          string.sub(input_file, string.len(cwd) - string.len(input_file) + 1))
    end
  else
    for _, case in ipairs(args) do M.test("input" .. case) end
  end
end
function M.test(case) print(case) end
return M
