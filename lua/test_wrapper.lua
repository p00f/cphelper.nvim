local s = require "plenary.scandir"
local f = require "plenary.filetype"
local h = require "helpers"
local run = require "run_test"
local fw = require "plenary.window.float"
local p = require "plenary.path"

local function compile(ft)
  local exit_status = 0
  if ft == 'c' then
    p.new(vim.fn.getcwd() .. p.path.sep .. "c.out"):rm()
    exit_status = os.execute(h.vglobal_or_default("cpp_compile_command",
                                                  "gcc solution.c -o c.out"))
  elseif ft == 'cpp' then
    p.new(vim.fn.getcwd() .. p.path.sep .. "cpp.out"):rm()
    exit_status = os.execute(h.vglobal_or_default("c_compile_command",
                                                  "g++ solution.cpp -o cpp.out"))
  else
  end
  return exit_status
end

local function cmd(ft)
  if (ft == "python") then
    return "python solution.py"
  elseif (ft == "c") then
    return "./c.out"
  elseif (ft == "cpp") then
    return "./cpp.out"
  else
  end
end

local function display(ac, cases, results)
  local header = "RESULTS: " .. ac .. "/" .. cases .. " AC"
  if ac == cases then header = header .. " 🎉🎉" end
  local bufnr = fw.centered_with_top_win({header}).bufnr
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, true, results)
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
  vim.api.nvim_buf_set_option(bufnr, 'filetype', 'Results')
  local highlights = {
    ["Status: AC"] = "DiffAdd",
    ["Status: WA"] = "Error",
    ["Case #\\d\\+"] = "DiffChange",
    ["Input:"] = "Underlined",
    ["Expected output:"] = "Underlined",
    ["Received output:"] = "Underlined"
  }
  for match, group in pairs(highlights) do vim.fn.matchadd(group, match) end
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<esc>', '<cmd>bd<CR>',
                              {noremap = true})
end

local M = {}

function M.wrapper(...)
  local args = {...}
  local cwd = vim.fn.getcwd()
  local ft = f.detect(vim.api.nvim_buf_get_name(0))
  local ac, cases = 0, 0
  local results = {}
  if compile(ft) == 0 then
    if #args == 0 then
      for _, input_file in ipairs(s.scan_dir(cwd, {
        search_pattern = "input%d+",
        depth = 1
      })) do
        local result, status = run.run_test(
                                   string.sub(input_file, string.len(cwd) -
                                                  string.len(input_file) + 1),
                                   cmd(ft))
        vim.list_extend(results, result)
        ac = ac + status
        cases = cases + 1
      end
    else
      for _, case in ipairs(args) do
        local result, status = run.run_test("input" .. case, cmd(ft))
        vim.list_extend(results, result)
        ac = ac + status
        cases = cases + 1
      end
    end
    display(ac, cases, results)
  else
    vim.api.nvim_err_writeln("Compilation error")
  end
end

function M.retest_wrapper(...)
  local args = {...}
  local cwd = vim.fn.getcwd()
  local ft = f.detect(vim.api.nvim_buf_get_name(0))
  local results = {}
  local ac, cases = 0, 0
  if #args == 0 then
    for _, input_file in ipairs(s.scan_dir(cwd, {
      search_pattern = "input%d+",
      depth = 1
    })) do
      local result, status = run.run_test(
                                 string.sub(input_file, string.len(cwd) -
                                                string.len(input_file) + 1),
                                 cmd(ft))
      vim.list_extend(results, result)
      ac = ac + status
      cases = cases + 1
    end
  else
    for _, case in ipairs(args) do
      local result, status = run.run_test("input" .. case, cmd(ft))
      vim.list_extend(results, result)
      ac = ac + status
      cases = cases + 1
    end
  end
  display(ac, cases, results)
end

return M
