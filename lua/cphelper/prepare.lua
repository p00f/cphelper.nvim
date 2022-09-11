local path = require("plenary.path")
local helpers = require("cphelper.helpers")
local def = require("cphelper.definitions")
local preferred_lang = vim.g["cph#lang"] or "cpp"
local contests_dir =
    path.new(vim.g["cph#dir"] or (vim.loop.os_homedir() .. path.path.sep .. "contests"))

local M = {}

-- Creates the folder for the problem: contests_dir/judge/contest/problem
--- @param problem string #The name of the problem
--- @param group string #Group, in the format "Judge - Contest"
--- @return Path #The problem dir
function M.prepare_folders(problem, group)
    local problem_dir
    if
        (group == "UVa Online Judge")
        or (group == "HDOJ")
        or (group == "DMOJ")
        or (group == "Library Checker")
    then
        problem_dir = contests_dir:joinpath(group, helpers.sanitize(problem))
    else
        local sep_pos = string.find(group, "% %-")
        local judge = helpers.sanitize(string.sub(group, 1, sep_pos))
        local contest = helpers.sanitize(string.sub(group, sep_pos + 1))
        problem = helpers.sanitize(problem)
        problem_dir = contests_dir:joinpath(judge, contest, problem)
    end
    problem_dir:mkdir({ exists_ok = true, parents = true })
    return problem_dir
end

-- Creates the sample input, sample output and solution source code files for the problem
--- @param problem_dir Path #The directory of the problem
--- @param tests table #List of { input = "foo", ouput = "bar" }
function M.prepare_files(problem_dir, tests)
    for i, test in pairs(tests) do
        problem_dir:joinpath("input" .. i):write(test.input, "w")
        problem_dir:joinpath("output" .. i):write(test.output, "w")
    end
    print("Wrote test(s)")
    local extension = def.extensions[preferred_lang]

    if vim.g["cph#rust#createjson"] then
        local sysroot =
            vim.fn.system({ "rustc", "--print", "sysroot" }):gsub("\n", ""):gsub("\r", "")
        problem_dir:joinpath("rust-project.json"):write(vim.g["cph#rust#json"] or (vim.json.encode({
            sysroot_src = sysroot .. "/lib/rustlib/src/rust/library/",
            crates = {
                {
                    root_module = "solution.rs",
                    edition = "2021",
                    deps = {},
                },
            },
        })), "w")
        print("Wrote rust-project.json")
    end

    vim.cmd("e " .. problem_dir:joinpath("solution." .. extension):absolute())
end

return M
