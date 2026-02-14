local util = require 'trim.util'

local highlighter = {
  is_pending = false,
}

local function add_whitespace_matches()
  if vim.w.trim_whitespace_match_ids == nil then
    vim.w.trim_whitespace_match_ids = {
      -- Trailing whitespaces
      vim.fn.matchadd('ExtraWhitespace', '\\s\\+$'),
      -- Trailing empty lines
      vim.fn.matchadd('ExtraWhitespace', '^\\_s*\\%$'),
    }
  end
end

local function delete_whitespace_matches()
  for _, matchid in ipairs(vim.w.trim_whitespace_match_ids or {}) do
    vim.fn.matchdelete(matchid)
  end
  vim.w.trim_whitespace_match_ids = nil
end

function highlighter.setup()
  local config = require('trim.config').get()

  vim.api.nvim_set_hl(0, 'ExtraWhitespace', {
    bg = config.highlight_bg,
    ctermbg = config.highlight_ctermbg,
  })

  local augroup = vim.api.nvim_create_augroup('TrimHighlight', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'WinEnter', 'TermEnter' }, {
    group = augroup,
    callback = function()
      local cfg = require('trim.config').get()
      if vim.bo.buftype == '' and not util.has_value(cfg.ft_blocklist, vim.bo.filetype) then
        add_whitespace_matches()
      else
        delete_whitespace_matches()
      end
    end,
  })
end

return highlighter
