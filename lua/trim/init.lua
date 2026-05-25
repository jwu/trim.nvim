---@class trim
---@field setup fun(opts?: trim.Config)
local M = {}

---Setup trim.nvim with user configuration.
---@param opt? trim.Config
function M.setup(opt)
  local config = require 'trim.config'
  config.setup(opt)
  local cfg = config.get()
  if cfg.trim_on_write then
    require('trim.trimmer').enable(true)
  end
end

return M
