
-- Keymaps for better default experience
-- See `:help vim.keymap.set()`
vim.keymap.set({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })
-- vim.keymap.set('n', '<leader>df', '<cmd>Format<CR>', { desc = "[f]ormat" })
-- Remap for dealing with word wrap
vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<leader>qc', '<cmd>cclose<CR>', { desc = "[q]uickfix [c]lose" })
vim.keymap.set('n', '<leader>qo', '<cmd>cope<CR>', { desc = "[q]uickfix [o]pen" })

