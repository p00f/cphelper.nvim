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
        },
}
