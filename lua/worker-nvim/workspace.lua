local M = {}

local Util = require("worker-nvim.util")
local Config = require("worker-nvim.config")

--------------------------------------------------------------------------------

---Returns all workspaces
---@return WorkspaceEntry[]
function M.get_workspaces()
  local directories = require("worker-nvim.config").config.directories

  ---@type WorkspaceEntry[]
  local workspace_list = {}

  -- Join all workspaces found
  for _, directory in pairs(directories) do
    local dir_workspaces = Util.get_dir_folders(directory)
    if dir_workspaces then
      workspace_list = vim.tbl_extend("force", workspace_list, dir_workspaces or {})
    end
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

---Opens a workspace
---@param path string
function M.open_workspace(path)
  Util.add_recent_data(path)

  Util.notify("Opening workspace " .. path)
  Util.notify("Running before_move hook" .. path)
  local hooks = Config.config.hooks or {}
  M.run_hook(hooks.before_move)

  -- Change directory
  vim.cmd.cd(path)

  Util.notify("Running after_move hook" .. path)
  M.run_hook(hooks.after_move)
end

--------------------------------------------------------------------------------

return M
