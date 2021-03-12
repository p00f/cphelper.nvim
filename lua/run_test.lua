local h = require("helpers")
local p = require("plenary.path")
local M = {}

function M.run_test(case, cmd)
    local case_no = string.sub(case, 6)
    local status = 0 -- status is 1 on correct answer, 0 otherwise
    local result = { "Case #" .. case_no }
    local input_arr = h.read_lines(case)
    local exp_out_arr = h.read_lines("output" .. case_no)
    vim.list_extend(result, { "Input:" })
    vim.list_extend(result, input_arr)
    vim.list_extend(result, { "Expected output:" })
    vim.list_extend(result, exp_out_arr)
    --cmd = cmd .. " <" .. case
    cmd = "./cpp.out <input1"
    local job_id = vim.fn.jobstart(cmd, {
        on_stdout = function(_, data, _)
            local message = "Received output: \n"
            for _, line in ipairs(data) do
                message = message .. line .. "\n"
            end
            vim.api.nvim_err_write(message)
            --vim.list_extend(result, { "Received output:" })
            --vim.list_extend(result, data)
            --if exp_out_arr == data then
            --    vim.list_extend(result, { "Status: AC" })
            --    status = 1
            --else
            --    vim.list_extend(result, { "Status: WA" })
            --end
        end,
        on_stderr = function(_, data, _)
            --vim.list_extend(result, { "Error: " })
            --vim.list_extend(result, data)
            --vim.list_extend(result, { "Status: RTE" })
            local message = "Error\n"
            for _, line in ipairs(data) do
                message = message .. line .. "\n"
            end
            vim.api.nvim_err_writeln(message)
        end,
    })
    print(job_id)
    result = h.pad(result, { pad_left = 1, pad_top = 1 })
    return result, status
end
return M
