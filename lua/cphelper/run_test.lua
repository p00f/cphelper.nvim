local fn = vim.fn
local extend = vim.list_extend
local insert = table.insert
local M = {}

--- @alias cphelper.StrListMatch "yes" | "trailing" | "no"

--- Compare two lists of strings
--- @param t1 table The first table
--- @param t2 table The second table
--- @return cphelper.StrListMatch
local function compare_str_list(t1, t2)
    --- @param str1 string
    --- @param str2 string
    --- @return cphelper.StrListMatch
    local compare = function(str1, str2)
        if str1 == str2 then
            return "yes"
        elseif str1:gsub("%s*$", "") == str2:gsub("%s*$", "") then
            return "trailing"
        else
            return "no"
        end
    end

    if #t1 ~= #t2 then
        return "no"
    end

    local trailing_match = false
    for k, _ in pairs(t1) do
        local matches = compare(t1[k], t2[k])
        if matches == "no" then
            return "no"
        elseif matches == "trailing" then
            trailing_match = true
        end
    end

    if trailing_match then
        return "trailing"
    else
        return "yes"
    end
end

--- Run a test case
--- @param case string #case no.
--- @param cmd string[] #command for running the test
--- @return table, integer #result to display and whether or not the test passed
function M.run_test(case, cmd)
    local timeout = vim.g["cph#timeout"] or 2000
    local success = 0 -- status is 1 on correct answer, 0 otherwise
    local display = { "Case #" .. case }
    local input_arr = fn.readfile("input" .. case)
    local exp_out_arr = fn.readfile("output" .. case)
    insert(display, "  Input:")
    for index, value in ipairs(input_arr) do
        input_arr[index] = "  " .. value
    end
    extend(display, input_arr)
    insert(display, "  Expected output:")
    for index, value in ipairs(exp_out_arr) do
        exp_out_arr[index] = "  " .. value
    end
    extend(display, exp_out_arr)
    local output_arr = {}
    local err_arr = {}

    local function on_stdout(_err, data)
        if not data then
            return
        end
        local lines = vim.split(data, "\n")
        for _, line in ipairs(lines) do
            extend(output_arr, { "  " .. line })
        end
        if output_arr[#output_arr] == "  " then
            output_arr[#output_arr] = nil -- EOF is an empty string
        end
    end

    local function on_stderr(_err, data)
        if not data then
            return
        end
        local lines = vim.split(data, "\n")
        for _, line in ipairs(lines) do
            extend(err_arr, { "  " .. line })
        end
        if err_arr[#err_arr] == "  " then
            err_arr[#err_arr] = nil -- EOF is an empty string
        end
    end

    local function on_exit(out)
        if out.signal == 15 and out.code == 124 then
            insert(display, string.format("  Status: Timed out after %d ms", timeout))
            return
        end

        if #output_arr ~= 0 then
            insert(display, "  Received output:")
            extend(display, output_arr)
        end
        if #err_arr ~= 0 then
            insert(display, "  Error:")
            extend(display, err_arr)
            insert(display, "  Exit code " .. out.code)
        end
        if out.code == 0 then
            local matches = compare_str_list(output_arr, exp_out_arr)
            if
                matches == "yes"
                or (matches == "trailing" and vim.g["cph#ignore_trailing_differences"])
            then
                insert(display, "  Status: AC")
                success = 1
            else
                insert(display, "  Status: WA")
                if matches == "trailing" then
                    insert(display, "  NOTE: Answer differs by trailing whitespace")
                end
            end
        else
            insert(display, "  Status: RTE")
            insert(display, "  Exit code " .. out.code)
        end
    end

    -- Run executable
    vim.system(cmd, {
        stdin = fn.readfile("input" .. case),
        stdout = on_stdout,
        stderr = on_stderr,
        timeout = timeout,
        text = true,
    }, on_exit):wait()

    insert(display, "")
    return display, success
end

return M
