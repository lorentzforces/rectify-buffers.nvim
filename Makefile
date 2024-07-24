SHELL := bash
.ONESHELL:
.SHELLFLAGS := -eu -o pipefail -c
.DELETE_ON_ERROR:
MAKEFLAGS += --warn-undefined-variables
MAKEFLAGS += --no-builtin-rules
.SILENT:

init: deps/.test-deps.sentinel
	echo "==BUILD== all dependencies up to date"
.PHONY: init

test: deps/.test-deps.sentinel
	nvim --headless --noplugin -u ./scripts/minimal_init.lua -c "lua MiniTest.run()" -c "exit"
	echo ""
.PHONY: test

deps/.test-deps.sentinel:
	mkdir -p $(@D)
	git clone --filter=blob:none https://github.com/echasnovski/mini.nvim $(@D)/mini.nvim
	touch $@
	echo "==BUILD== test dependencies installed"

clean-deps:
	rm -rf deps/
	echo "==BUILD== dependencies cleaned, run 'make init' to re-initialize dependencies"
.PHONY: clean-deps
