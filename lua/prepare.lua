local p = require("plenary.path")
local h = require("helpers")
local defns = require("definitions")
local contests_dir = p.new(vim.g.cphdir or (vim.loop.os_homedir() .. p.path.sep .. "contests"))
local preferred_lang = vim.g.cphlang or "cpp"

local M = {}

function M.prepare_folders(problem, group)
    -- group = judge + contest
    local sep_pos = string.find(group, "% %-")
    local judge = h.sanitize(string.sub(group, 1, sep_pos))
    local contest = h.sanitize(string.sub(group, sep_pos + 1))
    problem = h.sanitize(problem)
    local problem_dir = contests_dir:joinpath(judge, contest, problem)
    problem_dir:mkdir({ exists_ok = true, parents = true })
    return problem_dir
end

function M.prepare_files(problem_dir, tests)
    for i, test in pairs(tests) do
        problem_dir:joinpath("input" .. i):write(test["input"], "w")
        problem_dir:joinpath("output" .. i):write(test["output"], "w")
    end
    print("Wrote tests")
    local extension = defns["extensions"][preferred_lang]
    problem_dir:joinpath("solution." .. extension):touch()
    print("Wrote solution files")

    if vim.g.cph_rust_createjson then
        problem_dir:joinpath("rust-project.json"):write(vim.g.rustjson or ([[
{
     "sysroot_src": "]] .. vim.loop.os_homedir() .. [[/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/library/",
     "crates": [
             {
                 "root_module": "solution.rs",
                 "edition": "2018",
                 "deps": []
            }
     ]
}
]]), "w")
        print("Wrote rust-project.json")
    end

    vim.cmd("e " .. problem_dir:joinpath("solution." .. extension):absolute())
end

return M
