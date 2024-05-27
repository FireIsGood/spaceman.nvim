local M = {}

--------------------------------------------------------------------------------

---@class UserHooks
---@field before_move? string[] | function | nil
---@field after_move? string[] | function | nil

---@class UserConfig
---@field directories string[]
---@field sort_by_recent? boolean
---@field use_default_keymaps? boolean
---@field hooks? UserHooks
---@field data_path? string

---@type UserConfig
local default_config = {
  directories = {},
  sort_by_recent = true,
  use_default_keymaps = true,
  hooks = {
    before_move = nil,
    after_move = nil,
  },
  data_path = vim.fn.stdpath("data") .. "/worker-nvim_data.json",
}

---@param user_config UserConfig
function M.setup(user_config)
  M.config = vim.tbl_deep_extend("force", default_config, user_config or {})

  return M.config
end

--------------------------------------------------------------------------------

return M
