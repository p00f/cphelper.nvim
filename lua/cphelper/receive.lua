local prepare = require("cphelper.prepare")
local uv = vim.loop

local M = {}

function M.receive()
    print("Listening on port 27121")
    local buffer = ""
    M.server = uv.new_tcp()
    M.server:bind("127.0.0.1", 27121)
    M.server:listen(128, function(err)
        assert(not err, err)
        local client = uv.new_tcp()
        M.server:accept(client)
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
                    local json = vim.json.decode(buffer)
                    local problem_dir = prepare.prepare_folders(json.name, json.group)
                    prepare.prepare_files(problem_dir, json.tests)
                    print("All the best!")
                end)

                M.server:shutdown()
            end
        end)
    end)
    uv.run()
end

function M.stop()
    M.server:shutdown()
end

return M
