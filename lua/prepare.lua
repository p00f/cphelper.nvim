local p = require "plenary.path"
local contests_dir = p.new(vim.loop.os_homedir() .. "/contests")
-- if vim.api.nvim_get_var("cphdir") ~= nil then
--  contests_dir = p.new(vim.api.nvim_get_var("cphdir"))
-- end

local function sanitize(s)
  local unwanted = {"-", " ", "#", "%."}
  for _, char in pairs(unwanted) do
    local pos = string.find(s, char)
    while pos do
      s = string.sub(s, 1, pos - 1) .. string.sub(s, pos + 1)
      pos = string.find(s, char)
    end
  end
  return s
end

local M = {}

function M.prepare_folders(problem, group)
  -- group = judge + contest
  local sep_pos = string.find(group, "% %-")
  local judge = sanitize(string.sub(group, 1, sep_pos))
  local contest = sanitize(string.sub(group, sep_pos + 1))

  problem = sanitize(problem)
  local problem_dir = contests_dir:joinpath(judge, contest, problem)
  contests_dir:mkdir()
  contests_dir:joinpath(judge):mkdir()
  contests_dir:joinpath(judge, contest):mkdir()
  problem_dir:mkdir()
  return problem_dir()
end

function M.prepare_files(problem_dir, json) end
return M
