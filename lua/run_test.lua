local uv = vim.loop
local h = require "helpers"
local fw = require "plenary.window.float"
local M = {}

function M.run_test(case, cmd)

  local stdin = uv.new_pipe()
  local stdout = uv.new_pipe()
  local stderr = uv.new_pipe()

  -- Initialise arrays
  local result = {"Case #" .. string.sub(case, 6) .. ":"}
  local input_string = h.read_string(case)
  local input_arr = {"Input:"}
  vim.list_extend(input_arr, h.read_lines(case))
  local exp_out_arr = {"Expected output:"}
  vim.list_extend(exp_out_arr, h.read_lines("output" .. (string.sub(case, 6))))
  local output_arr = {}
  local output_string = ""
  local error_string = ""
  local err_arr = {}

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
      vim.list_extend(output_arr, h.split_lines(output_string))
      vim.list_extend(result, output_arr)
    end)
  end)

  -- Add to result
  vim.list_extend(result, input_arr)
  vim.list_extend(result, exp_out_arr)
  vim.list_extend(result, {"Received output:"})
  -- if string.len(error_string) == 0 then
  --  vim.list_extend(output_arr, output_arr1)
  vim.list_extend(result, output_arr) -- <-----
  -- else
  --  vim.list_extend(result, err_arr)
  -- end

  -- Floating window!!!
  return result

end
return M
