--  NOTE: Must happen before plugins are required (otherwise wrong leader will be used)
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
-- disable netrw to prevent issues with filetree plugin
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 2

require('custom')

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
