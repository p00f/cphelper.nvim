local contest_dir = "/home/p00f/contests" -- TODO 1) get os homedir
local lfs = require "lfs"                 --      2) allow user to set contest_dir

local function sanitize(s)
  local unwanted = {"-", " ", "#", "%."}
  for _, char in pairs(unwanted) do
    local occurrences = string.find(s, char)
    while occurrences do
      s = string.sub(s, 1, occurrences - 1) .. string.sub(s, occurrences + 1)
      occurrences = string.find(s, char)
    end
  end
  return s
end

local M = {}
function M.prepare_solution(problem, group)
  print(problem .. group)
  local sep_pos = string.find(group, " -")
  local success, message, code = lfs.mkdir(contest_dir) -- TODO add error handling here
  local judge = sanitize(string.sub(group, 1, sep_pos))
  lfs.mkdir(contest_dir .. "/" .. judge)                -- and here
  print("Prepared solution")
end
function M.prepare_tests(json) print("Prepared tests") end
return M
