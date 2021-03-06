local s = require "plenary.scandir"
local h = require "helpers"
local run = require "run_tests"

local function compile(ft)
  if ft == 'c' then
    os.execute(h.vglobal_or_default("cpp_compile_command",
                                    "gcc solution.c -o c.out"))
  elseif ft == 'cpp' then
    os.execute(h.vglobal_or_default("c_compile_command",
                                    "g++ solution.cpp -o cpp.out"))
  else
  end
end

local M = {}

function M.wrapper(...)
  local args = {...}
  local cwd = vim.fn.getcwd()
  local ft = vim.api.nvim_buf_get_var("ft")
  compile(ft)
  if #args == 0 then
    for _, input_file in ipairs(s.scan_dir(cwd, {
      search_pattern = "input%d+",
      depth = 1
    })) do
      run.run_tests(string.sub(input_file,
                               string.len(cwd) - string.len(input_file) + 1), ft)
    end
  else
    for _, case in ipairs(args) do run.run_tests("input" .. case, ft) end
  end
end

function M.retest_wrapper(...)
  local args = {...}
  local cwd = vim.fn.getcwd()
  local ft = vim.api.nvim_buf_get_var("ft")
  if #args == 0 then
    for _, input_file in ipairs(s.scan_dir(cwd, {
      search_pattern = "input%d+",
      depth = 1
    })) do
      run.run_tests(string.sub(input_file,
                               string.len(cwd) - string.len(input_file) + 1), ft)
    end
  else
    for _, case in ipairs(args) do run.run_tests("input" .. case, ft) end
  end
end

return M
