local M = {}

local Config = require("spaceman.config")

local keymap = vim.keymap.set

--------------------------------------------------------------------------------

local default_keymaps = {
  { command = "open_workspaces", keymap = "<leader>wo", description = "Open workspaces" },
  { command = "open_directories", keymap = "<leader>wd", description = "Open directories" },
  { command = "count_workspaces", keymap = "<leader>wc", description = "Count workspaces" },
  { command = "open_previous_workspace", keymap = "<leader>wp", description = "Previous workspace" },
}

-- Keymaps
function M.setup()
  if Config.config.use_default_keymaps then
    for _, binding in pairs(default_keymaps) do
      keymap("n", binding.keymap, function()
        require("spaceman")[binding.command]()
      end, { desc = binding.description })
    end
  end
end

--------------------------------------------------------------------------------

return M
