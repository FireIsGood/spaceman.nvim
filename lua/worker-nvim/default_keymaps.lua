local M = {}

local Config = require("worker-nvim.config")

local keymap = vim.keymap.set

--------------------------------------------------------------------------------

local default_keymaps = {
  { command = "list_workspaces", keymap = "<leader>wo", description = "List workspaces" },
}

-- Keymaps
function M.setup()
  if Config.config.use_default_keymaps then
    for _, binding in pairs(default_keymaps) do
      keymap("n", binding.keymap, function()
        require("worker-nvim")[binding.command]()
      end, { desc = binding.description })
    end
  end
end

--------------------------------------------------------------------------------

return M
