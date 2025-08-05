-- MIT License
-- 
-- Copyright (c) 2025 YuminosukeSato
-- 
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

-- improved test generator
local M = {}

-- 文字列先頭大文字化
local function upper_first(s) return (s:gsub("^%l", string.upper)) end

-- LSP でカーソル位置の関数シグネチャ取得
local function lsp_signature()
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  if #clients == 0 then return nil end
  
  local params = vim.lsp.util.make_position_params(0, clients[1].offset_encoding)
  local res = vim.lsp.buf_request_sync(0, "textDocument/signatureHelp", params, 500)
  if not res then return nil end
  for _, r in pairs(res) do
    local sig = r.result and r.result.signatures and r.result.signatures[1]
    if sig and sig.label then return sig.label end
  end
  return nil
end

-- シグネチャ文字列を解析し name args returns を返す
local function parse_sig(label)
  -- 例: func (s *Service) Do(ctx context.Context, id int) (string, error)
  local name = label:match("%s([%w_]+)%s*%(")
  local params = label:match("%((.*)%)")
  local rets = label:match("%)%s*%((.*)%)") or label:match("%)%s*([%w%*%[%]]+)$") or ""
  -- 引数分割
  local args = {}
  if params and #params > 0 then
    for part in params:gmatch("[^,]+") do
      part = vim.trim(part)
      local n, t = part:match("([%w_]+)%s+(.*)")
      if n and t then table.insert(args, {name = n, typ = t}) end
    end
  end
  -- 戻り値分割
  local rets_tbl = {}
  if #rets > 0 then
    for part in rets:gmatch("[^,]+") do
      part = vim.trim(part)
      table.insert(rets_tbl, part)
    end
  end
  return name, args, rets_tbl
end

-- フォールバックで Treesitter から関数名のみ取得
local function ts_fn_name()
  local ok, tsu = pcall(require, "nvim-treesitter.ts_utils")
  if not ok then return nil end
  local node = tsu.get_node_at_cursor()
  while node and node:type() ~= "function_declaration" and node:type() ~= "method_declaration" do
    node = node:parent()
  end
  if not node then return nil end
  local id = node:child(1)
  if not id then return nil end
  return vim.treesitter.get_node_text(id, 0)
end

-- テンプレート生成
local function template(pkg, fname, args, rets)
  -- args 構造体
  local args_lines = {}
  for _, a in ipairs(args) do
    table.insert(args_lines, string.format("\t\t%s %s", a.name, a.typ))
  end
  local want_field = (#rets == 0 or (#rets == 1 and rets[1] == "error")) and "\t\twantErr assert.ErrorAssertionFunc"
    or "\t\twant " .. rets[1] .. "\n\t\twantErr assert.ErrorAssertionFunc"
  local call_args = {}
  for _, a in ipairs(args) do table.insert(call_args, "tt.args." .. a.name) end
  local call = table.concat(call_args, ", ")

  return string.format([[
package %s_test

import (
    "context"
    "fmt"
    "testing"

    "github.com/stretchr/testify/assert"
)

func Test%s(t *testing.T) {
    type args struct {
%s
    }
    tests := []struct {
        name string
        args args
%s
    }{
        // TODO add cases
    }
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := %s(%s)
            if !tt.wantErr(t, err, fmt.Sprintf("%s(%s)")) {
                return
            }
            assert.Equalf(t, tt.want, got, "%s(%s)")
        })
    }
}
]], pkg, upper_first(fname), table.concat(args_lines, "\n"), want_field, fname, call, fname, call, fname, call)
end

-- 簡易的な関数名取得（フォールバック用）
local function simple_fn_name()
  local line = vim.api.nvim_get_current_line()
  local fname = line:match("func%s+([%w_]+)%s*%(") or line:match("func%s+%(.-%s([%w_]+)%s*%(")
  return fname
end

-- メイン
function M.generate()
  local src = vim.api.nvim_buf_get_name(0)
  if src:sub(-3) ~= ".go" then
    vim.notify("not a Go file")
    return
  end

  local sig = lsp_signature()
  local fname, argtbl, rettbl
  if sig then
    fname, argtbl, rettbl = parse_sig(sig)
  else
    fname = ts_fn_name() or simple_fn_name()
    argtbl, rettbl = {}, {}
    vim.notify("gopls unavailable, generating minimal template")
  end
  if not fname then
    vim.notify("function not detected")
    return
  end

  local test_path = src:gsub("%.go$", "_test.go")
  local pkg = vim.fn.fnamemodify(src, ":t"):gsub("%.go$", "")
  local content = template(pkg, fname, argtbl, rettbl)

  if vim.fn.filereadable(test_path) == 1 then
    vim.fn.writefile(vim.split("\n" .. content, "\n"), test_path, "a")
  else
    vim.fn.writefile(vim.split(content, "\n"), test_path)
  end
  vim.cmd("edit " .. test_path)
  vim.notify("generated test for " .. fname)
end

return M