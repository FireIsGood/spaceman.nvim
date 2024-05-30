local M = {}

local Util = require("spaceman.util")
local Config = require("spaceman.config")

local augroup = vim.api.nvim_create_augroup("spaceman", {})
local events = { "VimLeavePre" }
local has_loaded = false -- Do not save upon M.stop() unless we were in a session

--------------------------------------------------------------------------------

---Save the current session
function M.save()
  local session_path = M.get_session_path()
  Util.fs_ensure_path(session_path)
  vim.cmd(string.format("mksession! %s", session_path))
end

---Load the current session
function M.load()
  local session_path = M.get_session_path()
  Util.fs_ensure_path(session_path)
  vim.cmd(string.format("silent! source %s", session_path))
  has_loaded = true -- Now in a session
end

---Load the current session and enable autosaving
-- Used after switching workspaces
function M.start()
  M.load()
  vim.api.nvim_create_autocmd(events, {
    group = augroup,
    pattern = "*",
    callback = function()
      M.save()
    end,
  })
end

---Save the current session and disable autosaving
-- Used before switching workspaces
function M.stop()
  if has_loaded then
    M.save()
  end
  vim.api.nvim_clear_autocmds({ group = augroup })
  has_loaded = false -- No longer in any sessions
end

--------------------------------------------------------------------------------

function M.get_session_path()
  local session_name = Util.clean_path(vim.fn.getcwd())
  local session_path = vim.fs.normalize(Config.config.sessions_path)

  return session_path .. Util.fs_sep .. session_name .. ".session"
end

--------------------------------------------------------------------------------

return M
