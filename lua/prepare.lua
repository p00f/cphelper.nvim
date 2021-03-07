local p = require "plenary.path"
local h = require "helpers"
local contests_dir = p.new(h.vglobal_or_default("cphdir",
                                                (vim.loop.os_homedir() ..
                                                    p.path.sep .. "contests")))
local langs = {"c", "cpp", "py"}
local preferred_lang = h.vglobal_or_default("cphlang", "cpp")

local M = {}

function M.prepare_folders(problem, group)
  -- group = judge + contest
  local sep_pos = string.find(group, "% %-")
  local judge = h.sanitize(string.sub(group, 1, sep_pos))
  local contest = h.sanitize(string.sub(group, sep_pos + 1))

  problem = h.sanitize(problem)
  local judge_dir = contests_dir:joinpath(judge)
  local contest_dir = judge_dir:joinpath(contest)
  local problem_dir = contests_dir:joinpath(judge, contest, problem)
  if (not contests_dir:exists()) then contests_dir:mkdir() end
  if (not judge_dir:exists()) then judge_dir:mkdir() end
  if (not contest_dir:exists()) then contest_dir:mkdir() end
  if (not problem_dir:exists()) then problem_dir:mkdir() end
  return problem_dir
end

function M.prepare_files(problem_dir, tests)
  for i, test in pairs(tests) do
    problem_dir:joinpath("input" .. i):write(test["input"], "w")
    problem_dir:joinpath("output" .. i):write(test["output"], "w")
  end
  print("Wrote tests")
  for _, lang in pairs(langs) do
    problem_dir:joinpath("solution." .. lang):touch()
  end
  print("Wrote solution files")
  vim.cmd([[e ]] ..
              problem_dir:joinpath("solution." .. preferred_lang):absolute())
end

return M
