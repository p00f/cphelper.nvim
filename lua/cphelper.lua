--local http = require "http"
local pegasus = require "pegasus"
local servers = {}
local M = {}
function M.listen()
  local server = pegasus:new({port = "27121"})
  server:start(
    function(request, response)
      local headers = request:headers()
      local method = request:method()
      if method == "POST" then
        length = tonumber(headers["Content-Length"])
        vim.api.nvim_err_writeln("Content-Length: " .. length)
        if length > 0 then
          data = request:receiveBody()
          print("Read " .. #data .. " bytes.")
        end
      end
      response:write(data)
    end
  )
  table.insert(servers, server)
end
function M.killall()
  for i in servers do
    i:stop()
  end
end
return M
