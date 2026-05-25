-- trim.nvim luacheck configuration

std = luajit
codes = true
self = false

ignore = {
  "212", -- Unused argument
  "122", -- Indirectly setting a readonly global
}

globals = {}

read_globals = {
  "vim",
}
