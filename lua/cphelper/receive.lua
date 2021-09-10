local prepare = require("cphelper.prepare")
local uv = vim.loop

local function process(data)
    local json = vim.fn.json_decode(data)
    local problem_dir = prepare.prepare_folders(json.name, json.group)
    prepare.prepare_files(problem_dir, json.tests)
    print("All the best!")
end

local M = {}

function M.receive()
    print("Listening on port 27121")
    local buffer = ""
    local server = uv.new_tcp()
    server:bind("127.0.0.1", 27121)
    server:listen(128, function(err)
        assert(not err, err)
        local client = uv.new_tcp()
        server:accept(client)
        client:read_start(function(error, chunk)
            assert(not error, error)
            if chunk then
                buffer = buffer .. chunk
            else
                client:shutdown()
                client:close()
                local lines = {}
                for line in string.gmatch(buffer, "[^\r\n]+") do
                    table.insert(lines, line)
                end
                buffer = lines[#lines]
                vim.schedule(function()
                    process(buffer)
                end)
            end
        end)
    end)
    uv.run()
end

return M
