local M = {}

local uv = vim.loop

---@class WorkspaceEntry
---@field name string
---@field path string

--------------------------------------------------------------------------------

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
---Notifies with the 'msg' at the given 'level' of severity. Defaults to INFO
function M.notify(msg, level)
  level = level or "info"
  vim.notify(msg, vim.log.levels[level:upper()], { title = "worker.nvim" })
end

--------------------------------------------------------------------------------
-- Filesystem stuffs
--------------------------------------------------------------------------------

---Returns the file separator for the current OS
---@return string
function M.fs_sep()
  if not jit then
    return ""
  end

  local os = string.lower(jit.os)
  if os == "linux" or os == "osx" or os == "bsd" then
    return "/"
  else
    return "\\"
  end
end

---Returns a list of the folders in a directory
---@param path string
---@return WorkspaceEntry[]?
function M.get_dir_folders(path)
  local normalized_path = vim.fs.normalize(path)

  -- Get a directory iterator
  local dir_handler = uv.fs_scandir(normalized_path)
  if not dir_handler then
    return nil
  end

  -- Get all workspaces below the directory
  local workspace_list = {}
  while true do
    local name, type = uv.fs_scandir_next(dir_handler)
    if name == nil then
      break
    end
    if type == "directory" then
      ---@type WorkspaceEntry
      local entry = { name = "", path = "" }

      -- Modify the name a bit
      entry.name = string.gsub(" " .. name, "%W%l", string.upper):sub(2)
      entry.path = normalized_path .. M.fs_sep() .. name

      table.insert(workspace_list, entry)
    end
  end

  return workspace_list
end

--------------------------------------------------------------------------------

return M
