local server = require "http.server"
local headers = require "http.headers"
local lunajson = require "lunajson"
local prepare = require "prepare"
local M = {}

function M.pass()
  local s = server.listen {
    host = "localhost",
    port = 27121,
    onstream = function(_, stream) -- first arg is server
      local json = lunajson.decode(stream:get_body_as_string())
      prepare.prepare_solution(json.name, json.group)
      prepare.prepare_tests(json)
      local header = headers:new()
      header:append(":status", "201")
      stream:write_headers(header, true)
      print("All the best!")
      server:close()
    end
  }
  s:listen()
  s:loop()
end

return M
