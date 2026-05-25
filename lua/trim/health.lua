---@diagnostic disable: inject-field
local M = {}

function M.check()
  vim.health.start 'trim.nvim'

  -- Check Neovim version
  local v = vim.version()
  vim.health.ok('Neovim version: ' .. v.major .. '.' .. v.minor .. '.' .. v.patch)

  if vim.version.lt(v, { 0, 7, 0 }) then
    vim.health.error 'trim.nvim requires Neovim 0.7+'
  else
    vim.health.ok 'Neovim version requirement satisfied (0.7+)'
  end

  -- Check if module loads
  local ok, mod = pcall(require, 'trim')
  if not ok then
    vim.health.error('failed to load trim module: ' .. tostring(mod))
    return
  end

  if type(mod.setup) == 'function' then
    vim.health.ok 'module loaded: setup() available'
  else
    vim.health.error 'module loaded but setup() not found'
  end

  -- Check commands
  local has_trim = pcall(vim.api.nvim_buf_get_commands, 0, {})
  if pcall(vim.fn.exists, ':Trim') == 1 then
    vim.health.ok ':Trim command available'
  else
    vim.health.warn ':Trim command not found — is plugin loaded?'
  end

  if pcall(vim.fn.exists, ':TrimToggle') == 1 then
    vim.health.ok ':TrimToggle command available'
  else
    vim.health.warn ':TrimToggle command not found — is plugin loaded?'
  end

  -- Check if trim_on_write autocommand is active
  local has_autocmd = pcall(vim.api.nvim_get_autocmds, {
    group = 'TrimNvim',
    event = 'BufWritePre',
  })
  if has_autocmd then
    vim.health.ok 'trim_on_write autocommand is active'
  else
    vim.health.info 'trim_on_write autocommand is not active (may be disabled by config)'
  end

  -- Check highlight group
  if pcall(vim.api.nvim_get_hl, 0, { name = 'ExtraWhitespace' }) then
    vim.health.ok 'ExtraWhitespace highlight group exists'
  else
    vim.health.info 'ExtraWhitespace highlight group not defined (highlight may be disabled)'
  end
end

return M
