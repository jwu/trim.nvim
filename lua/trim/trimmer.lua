local api = vim.api
local util = require 'trim.util'

---@class trim.trimmer
local trimmer = {}

---Trim trailing whitespace in the current line only.
function trimmer.trim_current_line()
  local save = vim.fn.winsaveview()
  api.nvim_exec2(
    string.format('keepjumps keeppatterns silent! %d,%ds/\\s\\+$//e', save.lnum, save.lnum),
    {}
  )
  vim.fn.winrestview(save)
end

---Trim the buffer.
---When range is provided, only trim trailing whitespace in the given lines.
---When no range, apply all configured trim patterns.
---@param range? number non-zero if range was given
---@param line1? number start line of range
---@param line2? number end line of range
function trimmer.trim(range, line1, line2)
  local config = require('trim.config').get()
  local save = vim.fn.winsaveview()
  local bufnr = api.nvim_get_current_buf()

  -- Use extmark to track cursor position (auto-adjusts when lines are deleted)
  local ns_id = api.nvim_create_namespace 'trim_cursor'
  local extmark_id = api.nvim_buf_set_extmark(bufnr, ns_id, save.lnum - 1, save.col, {})

  if range and range > 0 then
    -- range specified: only trim trailing whitespace in the given range
    local cmd = string.format('keepjumps keeppatterns silent! %d,%ds/\\s\\+$//e', line1, line2)
    api.nvim_exec2(cmd, {})
  else
    -- trim_trailing with cursor line exclusion
    if config.trim_trailing and not config.trim_current_line then
      local lnum = save.lnum
      local last = api.nvim_buf_line_count(0)

      -- trim lines above cursor
      if lnum > 1 then
        local cmd = string.format('keepjumps keeppatterns silent! 1,%ds/\\s\\+$//e', lnum - 1)
        api.nvim_exec2(cmd, {})
      end
      -- trim lines below cursor
      if lnum < last then
        local cmd = string.format('keepjumps keeppatterns silent! %d,$s/\\s\\+$//e', lnum + 1)
        api.nvim_exec2(cmd, {})
      end
    end

    -- apply other patterns (trim_first_line, trim_last_line, custom patterns)
    for _, v in ipairs(config.patterns) do
      api.nvim_exec2(string.format('keepjumps keeppatterns silent! %s', v), {})
    end
  end

  -- Restore cursor position from extmark (which auto-adjusted)
  local pos = api.nvim_buf_get_extmark_by_id(bufnr, ns_id, extmark_id, {})
  api.nvim_buf_del_extmark(bufnr, ns_id, extmark_id)

  if pos and pos[1] then
    save.lnum = pos[1] + 1 -- extmark uses 0-indexed lines
    save.col = pos[2]
  end
  vim.fn.winrestview(save)
end

---Enable automatic trimming on BufWritePre.
---@param is_configured? boolean true when called from setup() (suppresses notification)
function trimmer.enable(is_configured)
  local opts = { pattern = '*' }
  local config = require('trim.config').get()
  vim.api.nvim_create_augroup('TrimNvim', { clear = true })
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = 'TrimNvim',
    pattern = opts.pattern,
    callback = function()
      if not util.has_value(config.ft_blocklist, vim.bo.filetype) then
        trimmer.trim()
      end
    end,
  })
  if config.notifications and not is_configured then
    vim.notify('TrimNvim enabled', vim.log.levels.INFO, { title = 'trim.nvim' })
  end
end

---Disable automatic trimming.
function trimmer.disable()
  pcall(vim.api.nvim_del_augroup_by_name, 'TrimNvim')
  if require('trim.config').get().notifications then
    vim.notify('TrimNvim disabled', vim.log.levels.INFO, { title = 'trim.nvim' })
  end
end

---Check if automatic trimming is enabled.
---@return boolean
function trimmer.is_enabled()
  local autocommands = api.nvim_get_autocmds({
    group = 'TrimNvim',
    event = 'BufWritePre',
  })
  return #autocommands > 0
end

---Toggle automatic trimming on/off.
function trimmer.toggle()
  if not trimmer.is_enabled() then
    trimmer.enable(false)
  else
    trimmer.disable()
  end
end

return trimmer
