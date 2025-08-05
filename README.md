# gogentest

![CI](https://github.com/YuminosukeSato/gogentest/workflows/CI/badge.svg)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Neovim plugin for generating Go test templates using LSP (gopls) to extract function signatures.

## ✨ Features

- 🚀 Automatically generates test templates for Go functions
- 🔍 Uses LSP (gopls) to extract function signatures with full type information
- 🔄 Falls back to Treesitter or minimal template when gopls is unavailable
- 📝 Generates Goland-compatible test templates with:
  - Proper args struct with typed fields
  - Table-driven test structure
  - Error handling with `assert.ErrorAssertionFunc`
  - Appropriate want fields based on return types

## 📋 Requirements

- Neovim 0.8+ (for LSP support)
- gopls (Go language server) - usually installed with Go development environment
- Optional: nvim-treesitter with Go parser for fallback support

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim) (Recommended)

```lua
return {
  {
    "YuminosukeSato/gogentest",
    ft = "go",
    dependencies = { "neovim/nvim-lspconfig" },
    keys = {
      { "<leader>tG", function() require("gogentest").generate() end, desc = "Generate Go Test" },
    },
  },
}
```

### LazyVim Full Configuration

If you're using LazyVim, create a file `~/.config/nvim/lua/plugins/gogentest.lua`:

```lua
return {
  {
    "YuminosukeSato/gogentest",
    ft = "go",
    dependencies = { "neovim/nvim-lspconfig" },
    keys = {
      { "<leader>tG", function() require("gogentest").generate() end, desc = "Generate Go Test" },
    },
    config = function()
      -- Optional: Add any custom configuration here
    end,
  },
  
  -- Ensure gopls is properly configured
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        gopls = {
          settings = {
            gopls = {
              analyses = {
                unusedparams = true,
              },
              staticcheck = true,
            },
          },
        },
      },
    },
  },
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "YuminosukeSato/gogentest",
  ft = "go",
  requires = { "neovim/nvim-lspconfig" },
  config = function()
    -- Optional keymapping
    vim.api.nvim_set_keymap('n', '<leader>tG', 
      ':lua require("gogentest").generate()<CR>', 
      { noremap = true, silent = true, desc = "Generate Go Test" })
  end,
}
```

## 🚀 Usage

1. Place your cursor on a Go function you want to test
2. Run `:GogentestGenerate` or use your configured keybinding (default: `<leader>tG`)
3. The plugin will:
   - Create a `*_test.go` file if it doesn't exist
   - Generate a test template with proper types extracted from gopls
   - Open the test file with the generated template

### Example

Given this Go function:
```go
func ProcessData(ctx context.Context, id int, data string) (string, error) {
    if id <= 0 {
        return "", errors.New("invalid id")
    }
    if data == "" {
        return "", errors.New("empty data")
    }
    return fmt.Sprintf("processed: %s (id: %d)", data, id), nil
}
```

The plugin generates:
```go
package mypackage_test

import (
    "context"
    "fmt"
    "testing"

    "github.com/stretchr/testify/assert"
)

func TestProcessData(t *testing.T) {
    type args struct {
        ctx  context.Context
        id   int
        data string
    }
    tests := []struct {
        name    string
        args    args
        want    string
        wantErr assert.ErrorAssertionFunc
    }{
        // TODO add cases
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := ProcessData(tt.args.ctx, tt.args.id, tt.args.data)
            if !tt.wantErr(t, err, fmt.Sprintf("ProcessData(%v, %v, %v)", tt.args.ctx, tt.args.id, tt.args.data)) {
                return
            }
            assert.Equalf(t, tt.want, got, "ProcessData(%v, %v, %v)", tt.args.ctx, tt.args.id, tt.args.data)
        })
    }
}
```

## ⚙️ Configuration

### Custom Keymappings

You can customize keymappings in your Neovim configuration:

```lua
-- In your init.lua or lua/config/keymaps.lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.keymap.set("n", "<leader>gt", function()
      require("gogentest").generate()
    end, { buffer = true, desc = "Generate Go test" })
  end,
})
```

### LazyVim Keymaps

If you prefer to configure keymaps separately in LazyVim:

```lua
-- In ~/.config/nvim/lua/config/keymaps.lua
local function map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, opts)
end

-- Go test generation
map("n", "<leader>tg", function() require("gogentest").generate() end, 
  { desc = "Generate Go test" })
```

## 🔧 How it works

1. **LSP First**: The plugin tries to get function signature from gopls using `textDocument/signatureHelp`
2. **Parse Signature**: Extracts function name, parameter names/types, and return types
3. **Generate Template**: Creates a table-driven test with proper type information
4. **Fallback**: If gopls is unavailable, falls back to Treesitter (function name only) or minimal template

## 🐛 Troubleshooting

### "gopls unavailable" message
Ensure gopls is installed and running:
```bash
go install golang.org/x/tools/gopls@latest
```

Then restart Neovim or run `:LspRestart`.

### "function not detected"
Make sure your cursor is on or inside a Go function declaration. The plugin looks for function signatures at the cursor position.

### Type information missing
Check that:
- gopls is properly configured
- The Go file has no syntax errors
- Your Go module is properly initialized (`go mod init`)

### LazyVim specific issues
If the plugin isn't loading:
1. Run `:Lazy sync` to ensure it's installed
2. Check `:Lazy` to see if the plugin is loaded
3. Verify the file type is detected as "go" with `:set ft?`

## 👨‍💻 Development

### Running Tests
```bash
make test
```

### Linting
```bash
make lint
```

### Format Code
```bash
make format
```

### Check All
```bash
make check
```

## 📄 License

MIT License - see [LICENSE](LICENSE) for details.

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 🙏 Acknowledgments

- Built with [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for testing
- Inspired by various Go test generation tools