local M = {}

--------------------------------------------------------------------------------

function M.open_workspaces()
  require("spaceman.workspace").open_workspaces()
end

function M.open_directories()
  require("spaceman.workspace").open_directories()
end

function M.count_workspaces()
  require("spaceman.workspace").count_workspaces()
end

---@param path string
function M.api_open_workspace(path)
  require("spaceman.workspace").open_workspace(path)
end

--------------------------------------------------------------------------------

---@param user_config? UserConfig
function M.setup(user_config)
  local config = require("spaceman.config").setup(user_config)

  require("spaceman.default_commands").setup()

  if config.use_default_keymaps then
    require("spaceman.default_keymaps").setup()
  end
end

--------------------------------------------------------------------------------

return M
