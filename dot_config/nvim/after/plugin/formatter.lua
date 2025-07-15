require("conform").setup({
  formatters = {
    styler = {
      -- hijacking "https://github.com/devOpifex/r.nvim",
      args = { "-s", "-e", "styler::style_file(commandArgs(TRUE))", "--args", "$FILENAME" },
      stdin = false,
    },
  },

  formatters_by_ft = {
    lua = { "stylua" },
    -- Conform will run multiple formatters sequentially
    python = { "isort", "black" },
    -- You can customize some of the format options for the filetype (:help conform.format)
    rust = { "rustfmt", lsp_format = "fallback" },
    -- Use the "*" filetype to run formatters on all filetypes.
    -- ["*"] = { "codespell" },
    -- Use the "_" filetype to run formatters on filetypes that don't
    -- have other formatters configured.
    r = { "styler" },
    quarto = { "styler" },
    ["_"] = { "trim_whitespace" },
  },
  default_format_opts = {
    lsp_format = "fallback",
  },
})

-- Create command that uses formatter if a filetype is defined of lsp otherwise
vim.keymap.set("n", "<leader>df", function()
  require('conform').format({ async = true })
end, { desc = "[f]ormat" })
