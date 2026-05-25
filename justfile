lua_dirs := 'lua plugin tests'

_default:
  @just --list

fmt:
  @command -v stylua >/dev/null || { echo 'stylua is required'; exit 127; }
  stylua {{lua_dirs}}

fmt-check:
  @command -v stylua >/dev/null || { echo 'stylua is required'; exit 127; }
  stylua --check {{lua_dirs}}

lint:
  @command -v selene >/dev/null || { echo 'selene is required'; exit 127; }
  selene {{lua_dirs}}
  lua -e "assert(loadfile('lua/trim/init.lua')); assert(loadfile('plugin/trim.lua'))"

test:
  nvim --headless -u tests/minimal_init.lua -c "lua require('plenary.test_harness').test_directory('tests/core')" -c "qa!"

check: fmt-check lint test
