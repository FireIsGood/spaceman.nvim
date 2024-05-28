local M = {}

local Config = require("spaceman.config")
local Util = require("spaceman.util")
local Workspace = require("spaceman.workspace")

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

--------------------------------------------------------------------------------

---@param opts table?
---Lists all workspaces under the configured directories
function M.list_workspaces(opts)
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

  local displayer = entry_display.create({
    separator = " ",
    items = {
      { width = name_width },
      {},
    },
  })

  local user_opts = Config.config.telescope_opts
  opts = vim.tbl_deep_extend("force", user_opts or {}, opts or {})
  pickers
    .new(opts, {
      prompt_title = "Open Workspace",
      results_title = "Workspaces",

      finder = finders.new_table({
        results = workspaces,
        ---@param entry WorkspaceEntry
        entry_maker = function(entry)
          return {
            value = entry,
            display = function(disp_entry)
              return displayer({
                { disp_entry.value.name },
                { disp_entry.value.path, "String" },
              })
            end,
            ordinal = entry.name, -- Does not do anything as sorting is done beforehand
          }
        end,
      }),

      sorter = conf.file_sorter(opts),

      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if selection and selection ~= "" then
            Workspace.open_workspace(selection.value.path)
          else
            Util.notify("No workspace selected", "warn")
          end
        end)
        return true
      end,
    })
    :find()
end

--------------------------------------------------------------------------------

return M