local M = {}

local Util = require("spaceman.util")
local Workspace = require("spaceman.workspace")

--------------------------------------------------------------------------------

---@param str string
---@param len number
local function pad_to_len(str, len)
  return str .. string.rep(" ", len - #str)
end

function M.open_workspaces()
  ---@type WorkspaceEntry[]
  local workspaces = Workspace.get_workspaces()

  if #workspaces == 0 then
    Util.notify("No workspaces found", "warn")
  end

  -- Get width to align all entries
  local name_width = 10
  for _, workspace in pairs(workspaces) do
    if #workspace.name > name_width then
      name_width = #workspace.name + 2
    end
  end

  vim.ui.select(
    workspaces,
    {
      prompt = "Open Workspace",
      ---@param entry WorkspaceEntry
      format_item = function(entry)
        return pad_to_len(entry.name, name_width) .. "  " .. entry.path
      end,
    },
    ---@param selection WorkspaceEntry?
    function(selection)
      if selection then
        Workspace.open_workspace(selection.path)
      else
        Util.notify("No workspace selected", "warn")
      end
    end
  )
end

function M.open_directories()
  ---@type WorkspaceEntry[]
  local directories = Workspace.get_directories()

  if #directories == 0 then
    Util.notify("No workspaces found", "warn")
  end

  -- Get width to align all entries
  local name_width = 10
  for _, directory in pairs(directories) do
    if #directory.name > name_width then
      name_width = #directory.name + 2
    end
  end

  vim.ui.select(
    directories,
    {
      prompt = "Open Workspace",
      ---@param entry WorkspaceEntry
      format_item = function(entry)
        return pad_to_len(entry.name, name_width) .. "  " .. entry.path
      end,
    },
    ---@param selection WorkspaceEntry?
    function(selection)
      if selection then
        Workspace.open_directory(selection.path)
      else
        Util.notify("No workspace selected", "warn")
      end
    end
  )
end

--------------------------------------------------------------------------------

return M
