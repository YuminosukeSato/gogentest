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

if vim.g.loaded_gogentest then
  return
end
vim.g.loaded_gogentest = true

local gogentest = require("gogentest")

-- Go言語ファイルでのみ有効なコマンドを作成
vim.api.nvim_create_user_command("GogentestGenerate", function()
  gogentest.generate()
end, { desc = "Generate Go test template for function at cursor" })

-- オプション: キーマッピングの設定例
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "go",
--   callback = function()
--     vim.keymap.set("n", "<leader>tG", function()
--       gogentest.generate()
--     end, { buffer = true, desc = "Generate Go test" })
--   end,
-- })