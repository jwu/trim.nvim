-- minimal_init.lua — minimal Neovim config for headless tests.

-- Add the plugin root to runtimepath.
vim.cmd('set rtp+=' .. vim.fn.getcwd())

-- Setup basic settings for testing
vim.opt.swapfile = false
vim.opt.termguicolors = true
