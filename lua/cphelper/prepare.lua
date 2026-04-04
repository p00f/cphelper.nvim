local def = require("cphelper.definitions")
local preferred_lang = vim.g["cph#lang"] or "cpp"
local sep = package.config:sub(1, 1)
local contests_dir = vim.g["cph#dir"] or (vim.uv.os_homedir() .. sep .. "contests")

local M = {}

--- Strip out special characters from a string
--- @param s string The string to sanitize
--- @return string
local function sanitize(s)
    local copy = s
    local unwanted = { "-", " ", "#", "%.", ":", "'", "+", "%%" }
    for _, char in pairs(unwanted) do
        local pos = string.find(copy, char)
        while pos do
            copy = string.sub(copy, 1, pos - 1) .. string.sub(copy, pos + 1)
            pos = string.find(copy, char)
        end
    end
    return copy
end
local function write_file(filepath, content)
    local f = assert(io.open(filepath, "w"))
    f:write(content)
    f:close()
end

--- Create the folder for the problem: contests_dir/judge/contest/problem
--- @param problem string name of the problem
--- @param group string group, in the format "Judge - Contest"
--- @return string # problem dir
function M.prepare_folders(problem, group)
    local problem_dir
    if
        (group == "UVa Online Judge")
        or (group == "HDOJ")
        or (group == "DMOJ")
        or (group == "Library Checker")
    then
        problem_dir = vim.fs.joinpath(contests_dir, group, sanitize(problem))
    else
        local sep_pos = string.find(group, "% %-")
        assert(sep_pos, "cphelper.nvim: could not find judge-contest separator")
        local judge = sanitize(string.sub(group, 1, sep_pos))
        local contest = sanitize(string.sub(group, sep_pos + 1))
        problem = sanitize(problem)
        problem_dir = vim.fs.joinpath(contests_dir, judge, contest, problem)
    end
    ---@cast problem_dir string
    vim.fn.mkdir(problem_dir, "p")
    return problem_dir
end

--- Create the sample input, sample output and solution source code files for the problem
--- @param problem_dir string # directory of the problem
--- @param tests table # list of { input = "foo", ouput = "bar" }
function M.prepare_files(problem_dir, tests)
    for i, test in pairs(tests) do
        write_file(vim.fs.joinpath(problem_dir, "input" .. i), test.input)
        write_file(vim.fs.joinpath(problem_dir, "output" .. i), test.output)
    end
    print("Wrote test(s)")
    local extension = def.extensions[preferred_lang]

    if vim.g["cph#rust#createjson"] then
        local sysroot =
            vim.fn.system({ "rustc", "--print", "sysroot" }):gsub("\n", ""):gsub("\r", "")
        write_file(
            vim.fs.joinpath(problem_dir, "rust-project.json"),
            vim.g["cph#rust#json"]
                or (
                    vim.json.encode({
                        sysroot_src = sysroot .. "/lib/rustlib/src/rust/library/",
                        crates = {
                            {
                                root_module = "solution.rs",
                                edition = "2021",
                                deps = {},
                            },
                        },
                    })
                )
        )
        print("Wrote rust-project.json")
    end

    vim.cmd("e " .. vim.fs.joinpath(problem_dir, "solution." .. extension))
end

return M
