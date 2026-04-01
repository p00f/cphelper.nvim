local prepare = require("cphelper.prepare")
local uv = vim.uv

local M = {}

---@param client uv.uv_tcp_t
local function on_connection(client)
    local buffer = ""
    client:read_start(function(error, chunk)
        assert(not error, error)
        if chunk then
            buffer = buffer .. chunk
        else
            client:shutdown()
            client:close()

            -- HTTP - CRLF b/w headers and body
            local content = string.match(buffer, "^.+\r\n(.+)$")
            assert(content, "cphelper.nvim: did not receive content from extension")

            vim.schedule(function()
                local request = vim.json.decode(content)
                if vim.g["cph#url_register"] then
                    vim.fn.setreg(vim.g["cph#url_register"], request.url)
                end
                local problem_dir = prepare.prepare_folders(request.name, request.group)
                prepare.prepare_files(problem_dir, request.tests)
                print("All the best!")
            end)
        end
    end)
end

function M.receive()
    print("Listening on port 27121")
    local server = uv.new_tcp()
    if not server then
        vim.api.nvim_echo({ { "could not create server" } }, true, { err = true })
        return
    else
        M.server = server
    end
    local bind_success, bind_error = M.server:bind("127.0.0.1", 27121)
    if not bind_success then
        vim.api.nvim_echo({ { "could not bind to port", bind_error } }, true, { err = true })
        return
    end
    M.server:listen(128, function(err)
        assert(not err, err)
        local client = uv.new_tcp()
        assert(client, "cphelper.nvim: could not create client")
        M.server:accept(client)
        on_connection(client)
    end)
end

function M.stop()
    M.server:shutdown()
end

return M
