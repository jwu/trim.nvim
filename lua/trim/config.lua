---@class trim.Config
---@field ft_blocklist string[]
---@field patterns string[]
---@field trim_on_write boolean
---@field trim_trailing boolean
---@field trim_last_line boolean
---@field trim_first_line boolean
---@field trim_current_line boolean
---@field highlight boolean
---@field highlight_bg string
---@field highlight_ctermbg string
---@field notifications boolean

---@type trim.Config
---@diagnostic disable-next-line: missing-fields
local M = {
  config = {},
}

---@type trim.Config
local default_config = {
  ft_blocklist = {},
  patterns = {},
  trim_on_write = true,
  trim_trailing = true,
  trim_last_line = true,
  trim_first_line = true,
  trim_current_line = true,
  highlight = false,
  highlight_bg = '#ff0000',
  highlight_ctermbg = 'red',
  notifications = true,
}

---Build trim patterns from config options.
---@param cfg trim.Config
---@return string[]
local function build_patterns(cfg)
  local patterns = {}

  for _, p in ipairs(cfg.patterns) do
    patterns[#patterns + 1] = p
  end

  if cfg.trim_trailing and cfg.trim_current_line then
    patterns[#patterns + 1] = [[%s/\s\+$//e]]
  end
  if cfg.trim_first_line then
    patterns[#patterns + 1] = [[%s/\%^\n\+//]]
  end
  if cfg.trim_last_line then
    patterns[#patterns + 1] = [[%s/\($\n\s*\)\+\%$//]]
  end

  return patterns
end

---Setup configuration with user options.
---@param opts? trim.Config
function M.setup(opts)
  opts = opts or {}

  -- compatability: disable -> ft_blocklist
  if opts.disable and not opts.ft_blocklist then
    vim.notify(
      '`disable` is deprecated, use `ft_blocklist` instead',
      vim.log.levels.WARN,
      { title = 'trim.nvim' }
    )
    opts.ft_blocklist = opts.disable
  end

  M.config = vim.tbl_deep_extend('force', default_config, opts)

  -- Build resolved patterns from config
  M.config.patterns = build_patterns(M.config)

  if M.config.highlight then
    require('trim.highlighter').setup()
  end
end

---Get current config.
---@return trim.Config
function M.get()
  return M.config
end

return M
