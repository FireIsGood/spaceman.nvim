local M = {}

local Util = require("spaceman.util")
local Config = require("spaceman.config")

--------------------------------------------------------------------------------

---Returns all workspaces
---@return WorkspaceEntry[]
function M.get_workspaces()
  local directories = require("spaceman.config").config.directories
  local custom_workspaces = require("spaceman.config").config.workspaces

  ---@type WorkspaceEntry[]
  local workspace_list = {}

  -- Join all workspaces found
  for _, directory in pairs(directories) do
    local dir_workspaces = Util.get_dir_folders(directory)
    if dir_workspaces then
      workspace_list = vim.tbl_extend("force", workspace_list, dir_workspaces or {})
    end
  end

  -- Join in the stray workspaces
  for _, workspace in pairs(custom_workspaces) do
    local name = ""
    local path = ""
    if type(workspace) == "string" then
      name = Util.fs_tail(workspace)
      path = workspace
    elseif type(workspace) == "table" then
      name = workspace[1]
      path = workspace[2]
    end

    table.insert(workspace_list, Util.create_entry(name, path))
  end

  table.sort(workspace_list, Util.sort_workspaces)

  return workspace_list
end

function M.get_directories()
  local directories = require("spaceman.config").config.directories

  local directory_list = {}

  for _, directory in pairs(directories) do
    local name = Util.fs_tail(directory)
    local path = directory
    table.insert(directory_list, Util.create_entry(name, path))
  end

  table.sort(directory_list, Util.sort_workspaces)

  return directory_list
end

---@param hook string[] | string | function
function M.run_hook(hook, path)
  -- Run single vim hook
  if type(hook) == "string" then
    vim.cmd(hook)
  end

  -- Run multiple vim hooks
  if type(hook) == "table" then
    for _, command in pairs(hook) do
      vim.cmd(command)
    end
  end

  -- Run function
  if type(hook) == "function" then
    hook(path)
  end
end

--------------------------------------------------------------------------------

---List workspaces
function M.open_workspaces()
  local adapter = Util.get_adapter()

  adapter.open_workspaces()
end

function M.open_directories()
  local adapter = Util.get_adapter()

  adapter.open_directories()
end

---Opens a workspace
---@param path string
function M.open_workspace(path)
  Util.add_recent_data(path)

  local hooks = Config.config.hooks or {}
  M.run_hook(hooks.before_move)

  -- Change directory
  vim.cmd.cd(path)

  M.run_hook(hooks.after_move)
end

---Counts and notifies the number of workspaces
function M.count_workspaces()
  local count = #M.get_workspaces()
  Util.notify(tostring(count) .. " Workspaces found")
end

--------------------------------------------------------------------------------

return M
