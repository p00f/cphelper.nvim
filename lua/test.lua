local s = require "plenary.scandir"

local function test(case, retest) -- receives the string inputxx

end

local M = {}

function M.wrapper(...)
  local args = {...}
  local cwd = vim.fn.getcwd()
  if #args == 0 then
    for _, input_file in ipairs(s.scan_dir(cwd, {
      search_pattern = "input%d+",
      depth = 1
    })) do
      test(string.sub(input_file, string.len(cwd) - string.len(input_file) + 1),
           false)
    end
  else
    for _, case in ipairs(args) do test("input" .. case, false) end
  end
end

function M.retest_wrapper(...)
  local args = {...}
  local cwd = vim.fn.getcwd()
  if #args == 0 then
    for _, input_file in ipairs(s.scan_dir(cwd, {
      search_pattern = "input%d+",
      depth = 1
    })) do
      test(string.sub(input_file, string.len(cwd) - string.len(input_file) + 1),
           true)
    end
  else
    for _, case in ipairs(args) do test("input" .. case, true) end
  end
end

return M
