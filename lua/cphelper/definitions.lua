local sep = require("plenary.path").path.sep
return {
    compile_cmd = {
        c = "gcc solution.c -o c.out",
        cpp = "g++ solution.cpp -o cpp.out",
        rust = "rustc solution.rs -o rust.out",
        kotlin = "kotlinc solution.kt -include-runtime -d solution.jar",
    },
    run_cmd = {
        c = [[.]] .. sep .. [[c.out]],
        cpp = [[.]] .. sep .. [[cpp.out]],
        java = "java solution.java",
        lua = "lua solution.lua",
        python = "python solution.py",
        rust = [[.]] .. sep .. [[rust.out]],
        kotlin = "java -jar solution.jar",
        javascript = "node solution.js",
    },
    extensions = {
        c = "c",
        cpp = "cpp",
        java = "java",
        python = "py",
        lua = "lua",
        rust = "rs",
        kotlin = "kt",
        javascript = "js",
    },
}
