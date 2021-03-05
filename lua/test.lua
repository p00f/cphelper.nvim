local p = require "plenary.path"
local M = {}

function M.wrapper(...)
  if #arg == 0 then

  else
    for _, case in pairs(...) do M.test(case) end
  end
end
function M.test(case) end
return M
