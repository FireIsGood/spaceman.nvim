local M = {}

local cmd = vim.api.nvim_create_user_command

--------------------------------------------------------------------------------

local default_user_commands = {
  { command = "open_workspaces", user_cmd = "Spaceman", description = "Open workspaces" },
  { command = "count_workspaces", user_cmd = "SpacemanCount", description = "Count workspaces" },
}

-- User commands
function M.setup()
  for _, binding in pairs(default_user_commands) do
    cmd(binding.user_cmd, function()
      require("spaceman")[binding.command]()
    end, { desc = binding.description })
  end
end

--------------------------------------------------------------------------------

return M
