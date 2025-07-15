--  TODO
require('lint').linters_by_ft = {
  make = { 'checkmake', },
}

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  callback = function()
    require("lint").try_lint()
  end,
})

vim.keymap.set("n", "<leader>dl",
  function()
    require('lint').try_lint()
  end,
  { desc = "[l]int" })
