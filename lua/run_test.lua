local h = require("helpers")
local p = require("plenary.path")
local M = {}

function M.run_test(case, cmd)
	local case_no = string.sub(case, 6)
	local status = 0
	local result = { "Case #" .. case_no }
	cmd = cmd .. " <" .. case
	local f = assert(io.popen(cmd, "r"))
	local s = assert(f:read("*a"))
	local rc = { f:close() }
	local input_arr = h.read_lines(case)
	local exp_out_arr = h.read_lines("output" .. case_no)
	local exp_out_string = p.new(vim.fn.getcwd() .. p.path.sep .. "output" .. case_no):read()
	local output_arr = h.split_lines(s)
	vim.list_extend(result, { "Input:" })
	vim.list_extend(result, input_arr)
	vim.list_extend(result, { "Expected output:" })
	vim.list_extend(result, exp_out_arr)
	if rc[1] == true then
		vim.list_extend(result, { "Received output:" })
		vim.list_extend(result, output_arr)
		if (s == exp_out_string) then
			vim.list_extend(result, { "Status: AC" })
			status = 1
		else
			vim.list_extend(result, { "Status: WA" })
		end
	else
		vim.list_extend(result, { "Error:" })
		vim.list_extend(result, output_arr)
	end
	if vim.fn.exists("validate") then
		result = h.pad(result, { pad_left = 1, pad_top = 1 })
	end
	return result, status
end
return M
