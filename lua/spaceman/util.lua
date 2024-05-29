local M = {}

local Config = require("spaceman.config")

local uv = vim.loop

---@class WorkspaceEntry
---@field name string
---@field path string
---@field last_opened string

--------------------------------------------------------------------------------

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
---Notifies with the 'msg' at the given 'level' of severity. Defaults to INFO
function M.notify(msg, level)
  level = level or "info"
  vim.notify(msg, vim.log.levels[level:upper()], { title = "spaceman.nvim" })
end

---@param a WorkspaceEntry
---@param b WorkspaceEntry
---@return boolean
function M.sort_workspaces(a, b)
  -- Sort by recent, then whether it has been opened, then fallback to name
  if Config.config.sort_by_recent then
    local a_l = a.last_opened
    local b_l = b.last_opened
    if a_l ~= "" and b_l ~= "" then
      return a_l > b_l
    elseif a_l == "" and b_l ~= "" then
      return false
    elseif a_l ~= "" and b_l == "" then
      return true
    end
  end

  return a.name > b.name
end

---Creates a WorkspaceEntry from data with an optional cached recent_data
---@param name string
---@param path string
---@param recent_data_pre table?
---@return WorkspaceEntry
function M.create_entry(name, path, recent_data_pre)
  local recent_data = recent_data_pre or M.read_recent_data()
  ---@type WorkspaceEntry
  local entry = { name = "", path = "", last_opened = "" }
  entry.path = path

  -- Run the rename function
  local rename_function = Config.config.rename_function
  if rename_function then
    entry.name = rename_function(name)
  else
    entry.name = name
  end

  entry.last_opened = recent_data[entry.path] or ""
  return entry
end

function M.get_adapter()
  local adapter_name = Config.config.adapter
  local adapter = require("spaceman.adapters.vim-ui")

  -- Switch to a specific adapter if possible
  local success = true
  if adapter_name == "telescope" then
    success, adapter = pcall(require, "spaceman.adapters.telescope")
  end

  if not success or not adapter then
    M.notify("Adapter incorrectly configured, falling back to vim-ui", "error")
    adapter = require("spaceman.adapters.vim-ui")
  end

  return adapter
end

--------------------------------------------------------------------------------
-- Filesystem stuffs
--------------------------------------------------------------------------------

---Returns the data path for recent data
---@return string?
function M.data_path()
  local data_path = Config.config.data_path
  return data_path and vim.fs.normalize(data_path)
end

---Adds a path to the recently used data at the current time
---@param path string
function M.add_recent_data(path)
  local data_path = M.data_path()
  if data_path == nil then
    return
  end

  local entry = {
    [path] = os.date("%Y-%m-%dT%H:%M:%S"),
  }

  local recent_data = vim.tbl_deep_extend("force", M.read_recent_data(), entry)

  require("spaceman.json").write(recent_data, data_path)
end

---Returns a list of paths and when they were last opened
function M.read_recent_data()
  local data_path = M.data_path()
  if data_path == nil then
    return {}
  end

  local recent_data = require("spaceman.json").read(data_path)
  return recent_data or {}
end

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

---@param path string
function M.remove_trailing_slash(path)
  if string.sub(path, #path, #path) == M.fs_sep() then
    path = string.sub(path, #path, #path - 1)
  end
  return path
end

---Returns a list of the folders in a directory
---@param path string
---@return WorkspaceEntry[]?
function M.get_dir_folders(path)
  local recent_data = M.read_recent_data()
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
      local full_path = M.remove_trailing_slash(path) .. M.fs_sep() .. name .. M.fs_sep()
      table.insert(workspace_list, M.create_entry(name, full_path, recent_data))
    end
  end

  return workspace_list
end

--------------------------------------------------------------------------------

return M
