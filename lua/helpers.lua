local M = {}

function M.sanitize(s)
  local unwanted = {"-", " ", "#", "%."}
  for _, char in pairs(unwanted) do
    local pos = string.find(s, char)
    while pos do
      s = string.sub(s, 1, pos - 1) .. string.sub(s, pos + 1)
      pos = string.find(s, char)
    end
  end
  return s
end

function M.vglobal_or_default(var, default)
  local exists, value = pcall(vim.api.nvim_get_var, var)
  if exists then
    return value
  else
    return default
  end
end
return M
