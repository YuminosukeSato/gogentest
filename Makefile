.PHONY: test lint format check-format

# Run tests
test:
	nvim --headless --noplugin -u tests/minimal_init.vim -c "PlenaryBustedDirectory tests/spec {sequential = true}"

# Run linter
lint:
	luacheck lua/ plugin/

# Format code
format:
	stylua .

# Check formatting without modifying files
check-format:
	stylua --check .

# Run all checks
check: check-format lint test

# Install development dependencies
install-dev:
	@echo "Please install the following tools manually:"
	@echo "  - stylua: https://github.com/JohnnyMorganz/StyLua"
	@echo "  - luacheck: luarocks install luacheck"
	@echo "  - plenary.nvim: git clone https://github.com/nvim-lua/plenary.nvim ../plenary.nvim"