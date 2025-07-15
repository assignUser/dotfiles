local ts_types = {
	'bash',
	'c',
	'cmake',
	'cpp',
	'go',
	'hcl',
	'lua',
	'markdown',
	'python',
	'r',
	'rust',
	'toml',
	'tsx',
	'typescript',
	'vim',
	'yaml',
}
require 'nvim-treesitter'.install(ts_types)

-- To enable highlighting but not install the non-existent language
vim.list_extend(ts_types, { 'codecompanion' })

-- enable TS syntax highlighting
vim.api.nvim_create_autocmd('FileType', {
	pattern = ts_types,
	callback = function()
		vim.treesitter.start()
	end,
})

require('nvim-treesitter-textobjects').setup {
	select = {
		enable = true,
		lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
		keymaps = {
			-- You can use the capture groups defined in textobjects.scm
			['aa'] = '@parameter.outer',
			['ia'] = '@parameter.inner',
			['af'] = '@function.outer',
			['if'] = '@function.inner',
			['ac'] = '@class.outer',
			['ic'] = '@class.inner',
		},
	},
	move = {
		enable = true,
		set_jumps = true, -- whether to set jumps in the jumplist
		goto_next_start = {
			[']m'] = '@function.outer',
			[']]'] = '@class.outer',
		},
		goto_next_end = {
			[']M'] = '@function.outer',
			[']['] = '@class.outer',
		},
		goto_previous_start = {
			['[m'] = '@function.outer',
			['[['] = '@class.outer',
		},
		goto_previous_end = {
			['[M'] = '@function.outer',
			['[]'] = '@class.outer',
		},
	},
	swap = {
		enable = true,
		swap_next = {
			['<leader>a'] = '@parameter.inner',
		},
		swap_previous = {
			['<leader>A'] = '@parameter.inner',
		},
	},
}
