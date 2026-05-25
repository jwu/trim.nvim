.PHONY: dev test lint format

dev:
	nvim --clean -u dev/init.lua

test:
	nvim --headless -u tests/init.lua -c "PlenaryBustedDirectory tests/core {minimal_init = 'tests/init.lua'}" -c "qa!"

lint:
	selene lua plugin tests
	luacheck lua tests

format:
	stylua lua plugin tests

check: format lint test
