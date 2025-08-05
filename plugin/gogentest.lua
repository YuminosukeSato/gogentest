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