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

function M.read_string(path)
  local file = io.open(path)
  if not file then return nil end
  local content = file:read "*a"
  file:close()
  return content
end

function M.read_lines(path)
  local lines = {}
  for line in io.lines(path) do table.insert(lines, line) end
  return lines
end

function M.split_lines(s)
  local lines = {}
  for ss in string.gmatch(s, "[^\r\n]+") do table.insert(lines, ss) end
  return lines
end

return M
