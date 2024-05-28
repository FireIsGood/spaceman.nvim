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
    local name = workspace[1]
    local path = workspace[2]
    table.insert(workspace_list, Util.create_entry(name, path))
  end

  table.sort(workspace_list, Util.sort_workspaces)

  return workspace_list
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
function M.list_workspaces()
  local adapter_name = Config.config.adapter
  local adapter = require("spaceman.adapters.vim-ui")

  -- Switch to a specific adapter if possible
  local success = true
  if adapter_name == "telescope" then
    success, adapter = pcall(require, "spaceman.adapters.telescope")
  end

  if not success or not adapter then
    Util.notify("Adapter incorrectly configured, falling back to vim-ui", "error")
    adapter = require("spaceman.adapters.vim-ui")
  end

  adapter.list_workspaces()
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
