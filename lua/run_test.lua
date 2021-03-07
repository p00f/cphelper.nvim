local uv = vim.loop
local h = require "helpers"
local p = require "plenary.path"
local M = {}

function M.run_test(case, cmd)
  local case_no = string.sub(case, 6)
  local stdin = uv.new_pipe()
  local stdout = uv.new_pipe()
  local stderr = uv.new_pipe()

  -- Initialise arrays
  local result = {"Case #" .. case_no .. ":"}
  local input_string = h.read_string(case)
  local input_arr = {"Input:"}
  vim.list_extend(input_arr, h.read_lines(case))
  local exp_out_arr = {"Expected output:"}
  vim.list_extend(exp_out_arr, h.read_lines("output" .. case_no))
  local output_string = ""
  local error_string = ""
  local err_arr = {}
  local test_output_path = p.new(
                               vim.fn.getcwd() .. p.path.sep .. "test_output" ..
                                   string.sub(case, 6))

  -- luv magic
  local handle, pid = uv.spawn(cmd, {stdio = {stdin, stdout, stderr}},
                               function(code, signal) -- on exit
  end)

  uv.read_start(stdout, function(err, data)
    assert(not err, err)
    if data then output_string = output_string .. data end
  end)
  print(output_string)

  uv.read_start(stderr, function(err, data)
    assert(not err, err)
    if data then error_string = error_string .. data end
  end)

  uv.write(stdin, input_string)

  uv.shutdown(stdin, function()
    uv.close(handle, function()
      test_output_path:write(output_string, "w")
    end)
  end)

  -- Add to result
  vim.list_extend(result, input_arr)
  vim.list_extend(result, exp_out_arr)
  vim.list_extend(result, {"Received output:"})
  -- if string.len(error_string) == 0 then
  --  vim.list_extend(output_arr, output_arr1)
  -------vim.list_extend(output_arr, h.split_lines(output_string))
 -- vim.list_extend(result, h.read_lines("test_output" .. string.sub(case, 6)))
  -- else
  --  vim.list_extend(result, err_arr)
  -- end

  -- Floating window!!!
  return result, case_no

end
return M
