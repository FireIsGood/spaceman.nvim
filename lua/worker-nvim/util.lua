local M = {}

local Config = require("worker-nvim.config")

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
  vim.notify(msg, vim.log.levels[level:upper()], { title = "worker.nvim" })
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

--------------------------------------------------------------------------------
-- Filesystem stuffs
--------------------------------------------------------------------------------

---Returns the data path for recent data
function M.data_path()
  return vim.fs.normalize(Config.config.data_path)
end

---Adds a path to the recently used data at the current time
---@param path string
function M.add_recent_data(path)
  local entry = {
    [path] = os.date("%Y-%m-%dT%H:%M:%S"),
  }

  local recent_data = vim.tbl_deep_extend("force", M.read_recent_data(), entry)

  require("worker-nvim.json").write(recent_data, M.data_path())
end

---Returns a list of paths and when they were last opened
function M.read_recent_data()
  local recent_data = require("worker-nvim.json").read(M.data_path())
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
      ---@type WorkspaceEntry
      local entry = { name = "", path = "", last_opened = "" }

      -- Modify the name a bit
      entry.name = string.gsub(" " .. name, "%W%l", string.upper):sub(2)
      entry.path = normalized_path .. M.fs_sep() .. name

      entry.last_opened = recent_data[entry.path] or ""

      table.insert(workspace_list, entry)
    end
  end

  return workspace_list
end

--------------------------------------------------------------------------------

return M
