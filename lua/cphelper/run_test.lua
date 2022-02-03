local helpers = require("cphelper.helpers")
local fn = vim.fn
local extend = vim.list_extend
local insert = table.insert
local M = {}

-- Run a test case
--- @param case number #Case no.
--- @param cmd string #Command for running the test
--- @return table, number #The result to display and whether or not the test passed
function M.run_test(case, cmd)
    local timeout = vim.g.cphtimeout or 2000
    local success = 0 -- status is 1 on correct answer, 0 otherwise
    local display = { "Case #" .. case }
    local input_arr = fn.readfile("input" .. case)
    local exp_out_arr = fn.readfile("output" .. case)
    insert(display, "Input:")
    extend(display, input_arr)
    insert(display, "Expected output:")
    extend(display, exp_out_arr)
    local output_arr = {}
    local err_arr = {}

    local function on_stdout(_, data, _)
        extend(output_arr, data)
        output_arr[#output_arr] = nil -- EOF is an empty string
    end

    local function on_stderr(_, data, _)
        extend(err_arr, data)
        err_arr[#err_arr] = nil
    end

    local function on_exit(_, exit_code, _)
        -- Strip CR on Windows
        if fn.has("win32") then
            for k, v in pairs(output_arr) do
                output_arr[k] = string.gsub(v, "\r", "")
            end
        end

        if #output_arr ~= 0 then
            insert(display, "Received output:")
            extend(display, output_arr)
        end
        if #err_arr ~= 0 then
            insert(display, "Error:")
            extend(display, err_arr)
            insert(display, "Exit code " .. exit_code)
        end
        if exit_code == 0 then
            local matches = helpers.compare_str_list(output_arr, exp_out_arr)
            if matches == "yes" then
                insert(display, "Status: AC")
                success = 1
            else
                insert(display, "Status: WA")
            end
            if matches == "trailing" then
                insert(display, "NOTE: Answer differs by trailing whitespace")
            end
        else
            insert(display, "Status: RTE")
            insert(display, "Exit code " .. exit_code)
        end
    end

    -- Run executable
    local job_id = fn.jobstart(cmd, {
        on_stdout = on_stdout,
        on_stderr = on_stderr,
        on_exit = on_exit,
        data_buffered = true,
    })

    -- Send input
    fn.chansend(job_id, extend(fn.readfile("input" .. case), { "" }))

    -- Wait till `timeout`
    local len = fn.jobwait({ job_id }, timeout)
    if len[1] == -1 then
        insert(display, string.format("Status: Timed out after %d ms", timeout))
        fn.jobstop(job_id)
    end

    return display, success
end
return M
