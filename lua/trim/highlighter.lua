local util = require 'trim.util'

local ns = vim.api.nvim_create_namespace 'trim_highlight'

---@class trim.highlighter
local highlighter = {}

---Add trailing whitespace extmarks for a buffer.
---@param bufnr integer
local function add_whitespace_extmarks(bufnr)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  -- Trailing whitespace on each line
  for linenr, line in ipairs(lines) do
    local s = line:find '%s+$'
    if s then
      vim.api.nvim_buf_set_extmark(bufnr, ns, linenr - 1, s - 1, {
        end_col = #line,
        hl_group = 'ExtraWhitespace',
        priority = 10,
      })
    end
  end

  -- Trailing blank lines at end of buffer
  local last = #lines
  while last > 0 and lines[last]:match '^%s*$' do
    last = last - 1
  end
  for i = last + 1, #lines do
    local len = #lines[i]
    if len > 0 then
      vim.api.nvim_buf_set_extmark(bufnr, ns, i - 1, 0, {
        end_col = len,
        hl_group = 'ExtraWhitespace',
        priority = 10,
      })
    end
  end
end

---Remove all whitespace extmarks for a buffer.
---@param bufnr integer
local function delete_whitespace_extmarks(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
end

---Evaluate and refresh highlights for the current buffer.
---@param bufnr? integer
local function refresh(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) then
    return
  end

  local cfg = require('trim.config').get()
  local should_highlight = vim.bo[bufnr].buftype == ''
    and not util.has_value(cfg.ft_blocklist, vim.bo[bufnr].filetype)

  delete_whitespace_extmarks(bufnr)
  if should_highlight then
    add_whitespace_extmarks(bufnr)
  end
end

local pending = false

---Schedule a debounced refresh to avoid excessive work on TextChanged.
local function schedule_refresh()
  if pending then
    return
  end
  pending = true
  vim.schedule(function()
    pending = false
    refresh()
  end)
end

---Setup trailing whitespace highlighting.
function highlighter.setup()
  local config = require('trim.config').get()

  vim.api.nvim_set_hl(0, 'ExtraWhitespace', {
    bg = config.highlight_bg,
    ctermbg = config.highlight_ctermbg,
    default = true,
  })

  local augroup = vim.api.nvim_create_augroup('TrimHighlight', { clear = true })

  -- Full highlight refresh on buffer/window enter
  vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'TermEnter' }, {
    group = augroup,
    callback = function()
      refresh()
    end,
  })

  -- Debounced refresh on text changes to keep highlights live while editing
  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    group = augroup,
    callback = schedule_refresh,
  })
end

return highlighter
