local prepare = require("cphelper.prepare")
local uv = vim.loop

local function processs(data)
    local json = vim.fn.json_decode(data)
    local problem_dir = prepare.prepare_folders(json.name, json.group)
    prepare.prepare_files(problem_dir, json.tests)
    print("All the best!")
end

local M = {}

function M.pass()
    local buffer = ""
    local server = uv.new_tcp()
    server:bind("127.0.0.1", 27121)
    server:listen(128, function(err)
        assert(not err, err)
        local client = uv.new_tcp()
        server:accept(client)
        client:read_start(function(err, chunk)
            assert(not err, err)
            if chunk then
                buffer = buffer .. chunk
            else
                client:shutdown()
                client:close()
                print(buffer)
            end
        end)
    end)
    print("TCP server listening at 127.0.0.1 port 27121")
    uv.run()
end

--[[ local lines = {}
for s in string.gmatch(str, "[^\r\n]+") do
    table.insert(lines, s)
end
 ]]
return M
