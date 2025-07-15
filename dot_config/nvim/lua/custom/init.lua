require('custom.plugins')
require('custom.remap')
require('custom.set')

vim.filetype.add(
  {
    filename = {
      ['just'] = 'just'
    },
    extension = {
      g = "antlr",
      g4 = "antlr4",
    }
  }
)
-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',
})
