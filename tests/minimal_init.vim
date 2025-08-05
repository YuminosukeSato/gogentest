" Minimal init for tests
set rtp+=.
set rtp+=../plenary.nvim
runtime plugin/plenary.vim

" Set up the runtime path to include the plugin being tested
lua << EOF
-- Add the plugin to the runtime path
vim.opt.runtimepath:prepend(vim.fn.expand('../'))
require('plenary.busted')
EOF