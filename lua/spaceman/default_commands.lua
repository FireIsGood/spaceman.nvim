local M = {}

local cmd = vim.api.nvim_create_user_command

--------------------------------------------------------------------------------

local default_keymaps = {
  { command = "list_workspaces", user_cmd = "WorkerList", description = "List workspaces" },
}

-- User commands
function M.setup()
  for _, binding in pairs(default_keymaps) do
    cmd(binding.user_cmd, function()
      require("spaceman")[binding.command]()
    end, { desc = binding.description })
  end
end

--------------------------------------------------------------------------------

return M
