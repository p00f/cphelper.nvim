return {
    compile_cmd = {
        c = "gcc solution.c -o c.out",
        cpp = "g++ solution.cpp -o cpp.out",
        rust = "rustc solution.rs -o rust.out",
    },
    run_cmd = {
        c = "./c.out",
        cpp = "./cpp.out",
        lua = "lua solution.lua",
        python = "python solution.py",
        rust = "./rust.out",
    },
    extensions = {
        c = "c",
        cpp = "cpp",
        python = "py",
        lua = "lua",
        rust = "rs",
    },
}
