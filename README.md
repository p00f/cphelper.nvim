# cphelper.nvim
A plugin for automating tasks in competitive programming like downloading testcases, compiling and testing. Supports C, C++ and Python.

## Requirements
- competitive-companion browser extension
- Plugin: `nvim-lua/plenary.nvim` (Install using your plugin manager)
- Luarocks: `http`.
	- If you use packer.nvim to manage plugins you can
	```lua
	use {'p00f/cphelper.nvim', rocks = 'http'}
	```
	- Otherwise install it from luarocks using
	`sudo luarocks install http`

## Instructions
- Use `:CphReceive` and press the "parse task" button in the extension to prepare files. This will open an empty solution file in your preferred language. (See )
- `:CphTest [numbers]` to test your solution. If testcase number(s) is specified, only those cases are run, otherwise all cases are run.
- `:CphRetest [numbers]` to test the same binary without recompiling.
- `:CphEdit [number]` to edit/add a testcase.
- `:CphDelete [numbers]` to delete testcases.

## Known Bugs
`:CphTest/Retest` have to be entered a number of times to get the full output. (There's an error the first couple of times)
