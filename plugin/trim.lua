if vim.g.load_trim_nvim then
  return
end
vim.g.load_trim_nvim = true

if not vim.api.nvim_create_autocmd then
  vim.notify_once('trim.nvim requires nvim 0.7.0+.', vim.log.levels.ERROR, { title = 'trim.nvim' })
  return
end

--------------------------------------------------------------------------------
-- <Plug> Mappings
--------------------------------------------------------------------------------

vim.keymap.set('n', '<Plug>(TrimLine)', function()
  require('trim.trimmer').trim_current_line()
end, { desc = 'Trim: trim trailing whitespace in current line' })

vim.keymap.set('n', '<Plug>(TrimBuffer)', function()
  require('trim.trimmer').trim()
end, { desc = 'Trim: trim entire buffer' })

vim.keymap.set('n', '<Plug>(TrimToggle)', function()
  require('trim.trimmer').toggle()
end, { desc = 'Trim: toggle automatic trimming on save' })

--------------------------------------------------------------------------------
-- User Commands
--------------------------------------------------------------------------------

vim.api.nvim_create_user_command('Trim', function(args)
  require('trim.trimmer').trim(args.range, args.line1, args.line2)
end, {
  range = '%',
  desc = 'Trim trailing whitespace and blank lines',
})

vim.api.nvim_create_user_command('TrimToggle', function()
  require('trim.trimmer').toggle()
end, {
  desc = 'Toggle automatic trimming on save',
})
