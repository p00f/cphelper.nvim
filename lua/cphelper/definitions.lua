return {
    compile_cmd = {
        c = "gcc solution.c -o c.out",
        cpp = "g++ solution.cpp -o cpp.out",
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
    rustc_args = "-o rust.out",
}
