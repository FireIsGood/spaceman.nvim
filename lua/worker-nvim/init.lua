local M = {}

--------------------------------------------------------------------------------

function M.list_workspaces()
  require("worker-nvim.telescope").list_workspaces()
end

---@param path string
function M.open_workspace(path)
  require("worker-nvim.workspace").open_workspace(path)
end

--------------------------------------------------------------------------------

---@param user_config UserConfig
function M.setup(user_config)
  local config = require("worker-nvim.config").setup(user_config)

  require("worker-nvim.default_commands").setup()

  if config.use_default_keymaps then
    require("worker-nvim.default_keymaps").setup()
  end
end

--------------------------------------------------------------------------------

return M
