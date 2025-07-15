vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = false

vim.o.spell = true
vim.o.spelllang = "en_us"
vim.o.spelloptions = "camel,noplainbuffer"

vim.o.swapfile = true
vim.o.backup = false
-- Set highlight on search
vim.o.hlsearch = true
vim.o.incsearch = true
-- Make line numbers default
vim.o.number = true
vim.o.relativenumber = true
vim.o.smartindent = false
vim.o.scrolloff = 15
-- Enable mouse mode
vim.o.mouse = 'a'
vim.cmd.colorscheme "catppuccin"
-- yank into both clipboard and primary selection
vim.o.clipboard = 'unnamed,unnamedplus'

-- Enable break indent
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case insensitive searching UNLESS /C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.o.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeout = true
vim.o.timeoutlen = 300

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menuone'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.lsp.inlay_hint.enable();
