# cphelper.nvim
A plugin for automating tasks in competitive programming like downloading test cases, compiling and testing. Supports Rust, C, C++, Python and Lua. Does not work on Windows. It should work on Linux, macOS and BSDs.

## Requirements
- [competitive-companion](https://github.com/jmerle/competitive-companion) browser extension (works with Firefox and all Chromium browsers)
- Plugin: [`nvim-lua/plenary.nvim`](https://github.com/nvim-lua/plenary.nvim/) (Install using your plugin manager)
- Luarocks: [`http`](https://daurnimator.github.io/lua-http/).
	- If you use packer.nvim to manage plugins you can
	```lua
	use {'p00f/cphelper.nvim', rocks = 'http', requires = 'nvim-lua/plenary.nvim'}
	```
	- Otherwise, see your neovim lua version using `:version` (the third line) (LuaJIT is 5.1) and then install it from luarocks using
	`sudo luarocks install http --lua-version <version>` (You need to have a lua version matching neovim's lua version installed. Most distros ship 5.4 by default, so you need to install other packages, for example `lua51` on archlinux.)


## Instructions
- Use `:CphReceive` and press the "parse task" button in the extension to prepare files. This will open an empty solution file in your preferred language. (See )
- `:CphTest [numbers]` to test your solution. If test case number(s) is specified, only those are run, otherwise, all cases are run.
- `:CphRetest [numbers]` to test the same binary without recompiling.
- `:CphEdit [number]` to edit/add testcases.
- `:CphDelete [numbers]` to delete testcases.

The filetype of the floating window showing results is `Results`, so you can disable your indentline/cursorline plugins for this filetype.
## Demo video

https://user-images.githubusercontent.com/36493671/117531842-39bc5880-b002-11eb-9e34-0b140bdf0065.mp4


## Prefs
- `g:cphdir` : The directory in which contests are stored (default `~/contests`) (Specify **absolute path**)
- `g:cphlang` : Preferred language for the first solution file opened. You can open another `solution.language` file for a particular problem using `:e` and that file will be used.
- `g:cph_rustc_args` : Arguments passed to rustc (default `-o rust.out`). Note: The output file must be `rust.out`.
- `g:c_compile_command` : Command for compiling C files (default `gcc solution.c -o c.out`). The input file must be `solution.c` and the output file must be `c.out`, this pref is  only for compile flags.
- `g:cpp_compile_command`: Command for compiling C++ files. See above. (default `g++ solution.cpp -o cpp.out`)
- `g:cphtimeout`: Time limit per test case in milliseconds (default 2000).
- `g:cph_rust_createjson`: Whether to create a `rust-project.json` for rust-analyzer. (default false)
- `g:cph_rustjson`: `rust-project.json` created for rust-analyzer (see above).You likely need to change this to the appropriate value for your setup if it doesn't work, mostly change `<home-directory>/.rustup/toolchains/stable-x86_64-unknown-linux-gnu` to the output of `rustc --print sysroot`. Default:
```jsonc
{
     "sysroot_src": "<home-directory>/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/library/",
     "crates": [
             {
                 "root_module": "solution.rs",
                 "edition": "2018",        // BE SURE TO CHECK THE EDITION WITH THE ONLINE JUDGE, THEIR VERSION MIGHT BE OLD.
                 "deps": []
            }
     ]
}
```
## Directory structure
```
Contests directory (g:cphdir)
├── Judge 1
│   ├── Contest 1
│   │   ├── Problem 1
│   │   │   ├── input1
│   │   │   ├── input2
│   │   │   ├── output1
│   │   │   ├── output2
│   │   │   ├── solution.c
│   │   │   ├── solution.cpp
│   │   │   └── solution.py
│   │   └── Problem 2
│   │       ├── input1
│   │       ├── output1
│   │       ├── solution.c
│   │       ├── solution.cpp
│   │       └── solution.py
│   └── Contest 2
│       └── Problem 1
│           ├── input1
│           ├── output1
│           ├── solution.c
│           ├── solution.cpp
│           └── solution.py
└── Judge 2
    └── Contest 2
        └── Problem 1
            ├── input1
            ├── output1
            ├── solution.c
            ├── solution.cpp
            └── solution.py
```
## Screenshot
<img src="https://raw.githubusercontent.com/p00f/cphelper.nvim/main/screenshot.png" />

## Known bugs
   None as of now :)
