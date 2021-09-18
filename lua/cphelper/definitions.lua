return {
    compile_cmd = {
        c = "gcc solution.c -o c.out",
        cpp = "g++ solution.cpp -o cpp.out",
        rust = "rustc solution.rs -o rust.out",
    },
    run_cmd = {
        c = vim.fn.has("win32") == 1 and ".\\c.out" or "./c.out",
        cpp = vim.fn.has("win32") == 1 and ".\\cpp.out" or "./cpp.out",
        lua = "lua solution.lua",
        python = "python solution.py",
        rust = vim.fn.has("win32") == 1 and ".\\rust.out" or "./rust.out",
    },
    extensions = {
        c = "c",
        cpp = "cpp",
        python = "py",
        lua = "lua",
        rust = "rs",
    },
}
