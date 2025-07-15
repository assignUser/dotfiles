require('mini.icons').setup()

require('mini.files').setup()
require('mini.comment').setup()
require('mini.cursorword').setup()
require('mini.starter').setup()
require('mini.surround').setup()
require('mini.pairs').setup()
require('mini.sessions').setup({
	directory = vim.fn.stdpath('state') .. '/sessions',
})

-- Commands to handle global sessions
vim.keymap.set('n', '<leader>ws', function()
		MiniSessions.write(vim.fn.fnamemodify(vim.fn.getcwd(), ":t") .. '.vim')
	end,
	{ desc = '[W]rite [S]ession for cwd' })

vim.api.nvim_create_user_command('CreateSession',
	function(args)
		MiniSessions.write(
			args.args,
			{ force = false }
		)
	end,
	{ nargs = 1, desc = "Create Session with custom name" })
vim.api.nvim_create_user_command('DeleteSession',
	function(args)
		MiniSessions.delete(
			args.args,
			{ force = true }
		)
	end,
	{ nargs = 1, desc = "Delete Session with custom name" })

-- Some additional mappings for mini.files
-- Set focused directory as current working directory
local set_cwd = function()
	local path = (MiniFiles.get_fs_entry() or {}).path
	if path == nil then return vim.notify('Cursor is not on valid entry') end
	vim.fn.chdir(vim.fs.dirname(path))
end

-- Yank in register full path of entry under cursor
local yank_path = function()
	local path = (MiniFiles.get_fs_entry() or {}).path
	if path == nil then return vim.notify('Cursor is not on valid entry') end
	vim.fn.setreg(vim.v.register, path)
end

-- Open path with system default handler (useful for non-text files)
local ui_open = function() vim.ui.open(MiniFiles.get_fs_entry().path) end

vim.api.nvim_create_autocmd('User', {
	pattern = 'MiniFilesBufferCreate',
	callback = function(args)
		local b = args.data.buf_id
		vim.keymap.set('n', 'g~', set_cwd, { buffer = b, desc = 'Set cwd' })
		vim.keymap.set('n', 'gX', ui_open, { buffer = b, desc = 'OS open' })
		vim.keymap.set('n', 'gy', yank_path, { buffer = b, desc = 'Yank path' })
	end,
})

vim.keymap.set('n', '<M-l>', function()
		local path = vim.fs.dirname(vim.fn.expand("%:p"))
		if path.gmatch(path, 'ministarter') then
			path = ""
		end
		MiniFiles.open(path)
	end,
	{ desc = "Open mini.files" })
