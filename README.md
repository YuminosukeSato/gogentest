# gogentest

A Neovim plugin for generating Go test templates using LSP (gopls) to extract function signatures.

## Features

- Automatically generates test templates for Go functions
- Uses LSP (gopls) to extract function signatures with full type information
- Falls back to Treesitter or minimal template when gopls is unavailable
- Generates Goland-compatible test templates with:
  - Proper args struct with typed fields
  - Table-driven test structure
  - Error handling with `assert.ErrorAssertionFunc`
  - Appropriate want fields based on return types

## Requirements

- Neovim 0.8+ (for LSP support)
- gopls (Go language server) - usually installed with Go development environment
- Optional: nvim-treesitter with Go parser for fallback support

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "your-username/gogentest",
  ft = "go",
  dependencies = { "neovim/nvim-lspconfig" }, -- for gopls
  keys = {
    { "<leader>tG", function() require("gogentest").generate() end, desc = "Generate Go Test" },
  },
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  "your-username/gogentest",
  ft = "go",
  requires = { "neovim/nvim-lspconfig" },
}
```

## Usage

1. Place your cursor on a Go function you want to test
2. Run `:GogentestGenerate` or use your configured keybinding (e.g., `<leader>tG`)
3. The plugin will:
   - Create a `*_test.go` file if it doesn't exist
   - Generate a test template with proper types extracted from gopls
   - Open the test file with the generated template

### Example

Given this Go function:
```go
func ProcessData(ctx context.Context, id int, data string) (string, error) {
    // implementation
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

## Configuration

You can add custom keymappings in your Neovim configuration:

```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "go",
  callback = function()
    vim.keymap.set("n", "<leader>gt", function()
      require("gogentest").generate()
    end, { buffer = true, desc = "Generate Go test" })
  end,
})
```

## How it works

1. **LSP First**: The plugin tries to get function signature from gopls using `textDocument/signatureHelp`
2. **Parse Signature**: Extracts function name, parameter names/types, and return types
3. **Generate Template**: Creates a table-driven test with proper type information
4. **Fallback**: If gopls is unavailable, falls back to Treesitter (function name only) or minimal template

## Troubleshooting

- **"gopls unavailable" message**: Ensure gopls is installed and running for your Go files
- **"function not detected"**: Make sure your cursor is on or inside a Go function declaration
- **Type information missing**: Check that gopls is properly configured and the file has no syntax errors

## License

MIT