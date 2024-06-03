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

---Cleans the path into a usable file name
-- This code emulates sessions.nvim for compatibility
---@param path string
function M.clean_path(path)
  local normalized_path = vim.fs.normalize(path)
  local cleaned_path, _ = normalized_path:gsub(M.fs_sep, ".")
  if M.fs_sep ~= "/" then
    return cleaned_path:sub(4) -- Windows `C:/`
  else
    return cleaned_path:sub(2) -- Linux `/`
  end
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

---Splits into the { dir, tail }
---@param path string
function M.fs_split_path(path)
  path = M.remove_trailing_slash(path) -- Ensure paths are `/one/two` and not `/one/two/`
  local parts = vim.split(path, M.fs_sep)

  if #parts == 1 then
    return "", parts[1]
  end

  local dir = vim.fn.join({ unpack(parts, 1, #parts - 1) }, M.fs_sep)
  local name = parts[#parts]

  return dir, name
end

---Returns the directory of the path
---@param path string
function M.fs_dir(path)
  local dir, _ = M.fs_split_path(path)
  return dir
end

---Returns the last entry of the path
---@param path string
function M.fs_tail(path)
  local _, name = M.fs_split_path(path)
  return name
end

---Returns the file separator for the current OS
---@return string
M.fs_sep = (function()
  if not jit then
    return ""
  end

  local os = string.lower(jit.os)
  if os == "linux" or os == "osx" or os == "bsd" then
    return "/"
  else
    return "\\"
  end
end)()

---Creates directories up to and not including the path
-- e.g. given /one/two/three.txt it will create /one/two
---@param path string
function M.fs_ensure_path(path)
  local dir = M.fs_dir(path)
  if dir ~= "" and vim.fn.isdirectory(dir) == 0 then
    if vim.fn.mkdir(dir, "p") == 0 then
      M.notify("Unable to make directory!", "error")
    end
  end
end

---@param path string
function M.remove_trailing_slash(path)
  if path:sub(#path, #path) == M.fs_sep then
    path = path:sub(1, #path - 1)
  end
  return path
end

---@param path string
function M.add_trailing_slash(path)
  if string.sub(path, #path, #path) ~= M.fs_sep then
    path = path .. M.fs_sep
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
      local full_path = M.remove_trailing_slash(path) .. M.fs_sep .. name .. M.fs_sep
      table.insert(workspace_list, M.create_entry(name, full_path, recent_data))
    end
  end

  return workspace_list
end

--------------------------------------------------------------------------------

return M
