local M = {}

--------------------------------------------------------------------------------

---@class UserHooks
---@field before_move? string[] | string | function | nil
---@field after_move? string[] | string | function | nil

---@alias UserWorkspace string | string[]

---@class UserConfig
---@field directories string[]
---@field workspaces UserWorkspace[]
---@field sort_by_recent? boolean
---@field use_default_keymaps? boolean
---@field use_default_hooks? boolean
---@field use_sessions? boolean
---@field adapter? "telescope" | "vim-ui"
---@field rename_function? function | nil
---@field hooks? UserHooks
---@field directory_function? function | nil
---@field telescope_opts? table?
---@field data_path? string?
---@field sessions_path? string?

---@type UserConfig
local default_config = {
  directories = {},
  workspaces = {},
  sort_by_recent = true,
  use_default_keymaps = false,
  use_default_hooks = true,
  use_sessions = true,
  adapter = "telescope",
  rename_function = nil,
  hooks = {
    before_move = nil,
    after_move = nil,
  },
  directory_function = nil,
  telescope_opts = nil,
  data_path = vim.fn.stdpath("data") .. "/spaceman_data.json",
  sessions_path = vim.fn.stdpath("data") .. "/sessions",
}

---@param user_config UserConfig?
function M.setup(user_config)
  M.config = vim.tbl_deep_extend("force", default_config, user_config or {})

  return M.config
end

--------------------------------------------------------------------------------

return M
