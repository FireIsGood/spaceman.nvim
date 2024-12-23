local M = {}

--------------------------------------------------------------------------------

---@class UserHooks
---@field before_move? string[] | string | function | nil: Hook to do before a move
---@field after_move? string[] | string | function | nil: Hook to do after a move

---@alias UserWorkspace string | string[]: Workspace path or path with label

---@class UserConfig
---@field directories string[]: List of directories storing workspaces
---@field workspaces UserWorkspace[]: List of individual workspaces
---@field sort_by_recent? boolean: Whether to sort workspaces and directories by recently used
---@field use_default_keymaps? boolean: Whether to use default keymaps
---@field use_default_hooks? boolean: Whether to use default hooks
---@field use_sessions? boolean: Whether to use Spaceman sessions
---@field adapter? "telescope" | "vim-ui": Which adapter to use
---@field rename_function? function | nil: Function run on every directory for display
---@field hooks? UserHooks: Hooks to run before and after moving
---@field directory_function? function | nil: Function run on every directories for display
---@field telescope_opts? table?: Options for Telescope
---@field data_path? string?: Path to file where data is stored
---@field sessions_path? string?: Path to folder where sessions are saved

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
