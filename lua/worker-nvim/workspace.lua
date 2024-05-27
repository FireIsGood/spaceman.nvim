local M = {}

local Util = require("worker-nvim.util")

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

---Opens a workspace
---@param workspace WorkspaceEntry
function M.open_workspace(workspace)
  Util.notify("Opening workspace " .. workspace.name)

  Util.notify("Adding" .. workspace.path .. " to recents")
  Util.add_recent_data(workspace.path)
end

--------------------------------------------------------------------------------

return M
