local M = {}

local Util = require("spaceman.util")

--------------------------------------------------------------------------------

---Write a table to the path
---@param table table
---@param path string
function M.write(table, path)
  local normalized_path = vim.fs.normalize(path)
  -- Encode our data
  local data = vim.json.encode(table)

  -- Create the path up to the file if needed
  Util.fs_ensure_path(normalized_path)

  -- Open the file
  local file, err = io.open(normalized_path, "w+")
  if not file then
    Util.notify("Could not open file: " .. err, "error")
    return
  end

  -- Write our data
  file:write(data)
  file:close()
end

---Read a json file from the path
---@param path string
---@return table?
function M.read(path)
  local normalized_path = vim.fs.normalize(path)
  -- Open the file
  local file, _ = io.open(normalized_path, "r")
  if not file then
    M.write({}, normalized_path)
    return {}
  end

  -- Read our data
  local encoded_data = file:read("*a")
  file:close()

  return vim.json.decode(encoded_data)
end

--------------------------------------------------------------------------------

return M
