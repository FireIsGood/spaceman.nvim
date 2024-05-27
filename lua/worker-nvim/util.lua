local M = {}

--------------------------------------------------------------------------------

---@param msg string
---@param level? "info"|"trace"|"debug"|"warn"|"error"
---Notifies with the 'msg' at the given 'level' of severity. Defaults to INFO
function M.notify(msg, level)
  level = level or "info"
  vim.notify(msg, vim.log.levels[level:upper()], { title = "worker.nvim" })
end

--------------------------------------------------------------------------------

return M
