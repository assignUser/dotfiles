--
-- Install package manager
--    https://github.com/folke/lazy.nvim
--    `:help lazy.nvim.txt` for more info
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system {
		'git',
		'clone',
		'--filter=blob:none',
		'https://github.com/folke/lazy.nvim.git',
		'--branch=stable', -- latest stable release
		lazypath,
	}
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
	-- Color schemes
	{
		"catppuccin/nvim",
		name = "catppuccin",
		opts = {
			flavour = 'macchiato',
			styles = { keywords = { "italic" } },
			dim_inactive = { enabled = true },
			custom_highlights = function(colors)
				return {
					DiagnosticUnderlineError = { style = { "undercurl" }, sp = colors.red }, -- Used to underline "Error" diagnostics
					DiagnosticUnderlineWarn  = { style = { "undercurl" }, sp = colors.yellow }, -- Used to underline "Warning" diagnostics
					DiagnosticUnderlineInfo  = { style = { "undercurl" }, sp = colors.blue }, -- Used to underline "Information" diagnostics
					DiagnosticUnderlineHint  = { style = { "undercurl" }, sp = colors.teal }, -- Used to underline "Hint" diagnostics
					LspInlayHint             = { fg = colors.overlay0, bg = colors.bg }
				}
			end

		}
	},
	{ "rose-pine/neovim",      name = "rose-pine" },
	-- Detect tabstop and shiftwidth automatically
	'nmac427/guess-indent.nvim',
	{
		-- Highlight, edit, and navigate code
		'nvim-treesitter/nvim-treesitter',
		lazy = false,
		branch = 'main',
		-- build = ':TSUpdate',
		dependencies = {
			{ 'nvim-treesitter/nvim-treesitter-textobjects', branch = 'main' },
		},
	},
	{ 'nvim-treesitter/nvim-treesitter-context', dependencies = 'nvim-treesitter/nvim-treesitter' },
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {
			indent = { enabled = true },
			gitbrowse = { enabled = true },
			image = { enabled = true },
			notifier = { timeout = 3000, style = "compact", height = { min = 1, max = 0.8 }, width = { min = 1, max = 0.5 } },
			scratch = { enabled = true },
			lazygit = {
				enabled = true,
				config = {
					gui = {
						theme = {
							activeBorderColor = { "#8bd5ca", true },
							searchingActiveBorderColor = { "#8bd5ca", true },
						}
						,
					},
				}
			},
		},
		keys = {
			{ "<leader>gB", function() Snacks.gitbrowse() end,             desc = "Git Browse",               mode = { "n", "v" } },
			{ "<leader>gg", function() Snacks.lazygit() end,               desc = "Lazygit" },
			{ "<leader>n",  function() Snacks.notifier.show_history() end, desc = "Show Notification history" },
			{ "<leader>.",  function() Snacks.scratch() end,               desc = "Toggle Scratch Buffer" },
			{ "<leader>S",  function() Snacks.scratch.select() end,        desc = "Select Scratch Buffer" },
		}
	},
	-- LSP config in after/plugin/lsp.lua
	{
		'mrcjkb/rustaceanvim',
		version = '^6',
		lazy = false, -- This plugin is already lazy
		init = function()
			vim.g.rustaceanvim = {
				server = {
					on_attach = function(client, bufnr)
						-- you can also put keymaps in here
					end,
					default_settings = {
						-- rust-analyzer language server configuration
						['rust-analyzer'] = {
							inlayHints = {
								closureCaptureHints = { enable = true },
								implicitDrops = { enable = false },
								genericParameterHints = {
									lifetime = {
										enable = true
									},
								},
							},
							diagnostics = {
								styleLints = { enable = true, },
								enable = true,
							},
							cargo = {
								allFeatures = true,
							},
						},
					},
				},
			}
		end,


	},
	{
		-- LSP Configuration & Plugins
		'neovim/nvim-lspconfig',
		dependencies = {
			-- Automatically install LSPs to stdpath for neovim
			'mason-org/mason.nvim',
			{ 'mason-org/mason-lspconfig.nvim' },
			-- Useful status updates for LSP
			{ 'j-hui/fidget.nvim',             opts = {} },
		},
	},
	{
		"folke/lazydev.nvim",
		dependencies = { 'justinsgithub/wezterm-types' },
		ft = "lua",
		opts = {
			library = {
				{ path = "wezterm-types", mods = { "wezterm" } },
			},
			enabled = function(root_dir)
				return vim.g.lazydev_enabled == nil and true or vim.g.lazydev_enabled
			end,

		}
	},
	{ 'mfussenegger/nvim-lint' },
	{
		'stevearc/conform.nvim',
		opts = {},
	},
	{ 'WhoIsSethDaniel/mason-tool-installer.nvim' },
	{
		'saghen/blink.cmp',
		dependencies = { 'rafamadriz/friendly-snippets' },
		-- use a release tag to download pre-built binaries
		version = '1.*',
		---@module 'blink.cmp'
		---@type blink.cmp.Config
		opts = {
			keymap = {
				preset = "default"
			},
			sources = {
				default = { "lazydev", "lsp", "path", "snippets", "buffer" },
				providers = {
					lazydev = {
						name = "LazyDev",
						module = "lazydev.integrations.blink",
						-- make lazydev completions top priority (see `:h blink.cmp`)
						score_offset = 100,
					},
				},
			},
		},
	},

	-- Useful plugin to show you pending keybinds.
	{ 'folke/which-key.nvim',                     opts = {} },
	{
		-- Adds git releated signs to the gutter, as well as utilities for managing changes
		'lewis6991/gitsigns.nvim',
		opts = {
			-- See `:help gitsigns.txt`
			signs = {
				add = { text = '+' },
				change = { text = '~' },
				delete = { text = '_' },
				topdelete = { text = '‾' },
				changedelete = { text = '~' },
			},
		},
	},
	{
		"folke/trouble.nvim",
		branch = "main",
		keys = {
			{
				"<leader>xX",
				"<cmd>Trouble diagnostics toggle<cr>",
				desc = "Diagnostics (Trouble)",
			},
			{
				"<leader>xx",
				"<cmd>Trouble diagnostics toggle filter.buf=0<cr>",
				desc = "Buffer Diagnostics (Trouble)",
			},
			{
				"<leader>cs",
				"<cmd>Trouble symbols toggle focus=false<cr>",
				desc = "Symbols (Trouble)",
			},
			{
				"<leader>cl",
				"<cmd>Trouble lsp toggle focus=false win.position=right<cr>",
				desc = "LSP Definitions / references / ... (Trouble)",
			},
			{
				"<leader>xL",
				"<cmd>Trouble loclist toggle<cr>",
				desc = "Location List (Trouble)",
			},
			{
				"<leader>xQ",
				"<cmd>Trouble qflist toggle<cr>",
				desc = "Quickfix List (Trouble)",
			},
		},
		opts = {}, -- for default options, refer to the configuration section for custom setup.
	},
	{
		-- Set lualine as statusline
		'nvim-lualine/lualine.nvim',
		-- See `:help lualine.txt`
		opts = {
			options = {
				icons_enabled = true,
				theme = 'catppuccin',
				component_separators = '|',
				section_separators = '',
			},
		},
	},
	{ 'echasnovski/mini.nvim', version = '*' },
	{
		"ibhagwan/fzf-lua",
		dependencies = { "echasnovski/mini.icons" },
		opts = { "telescope" },
		init = function(self)
			local builtin = require('fzf-lua')
			vim.keymap.set('n', '<leader>?', builtin.oldfiles, { desc = '[?] Find recently opened files' })
			vim.keymap.set('n', '<leader><space>', builtin.buffers, { desc = '[ ] Find existing buffers' })
			vim.keymap.set('n', '<leader>/', builtin.blines,
				{ desc = '[/] Fuzzily search in current buffer' })
			vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
			vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
			vim.keymap.set('n', '<leader>sf', builtin.files, { desc = '[S]earch [F]iles' })
			vim.keymap.set('n', '<leader>sh', builtin.helptags, { desc = '[S]earch [H]elp' })
			vim.keymap.set('n', '<leader>sg', builtin.live_grep_native, { desc = '[S]earch by [G]rep' })
			vim.keymap.set('n', '<leader>sd', builtin.diagnostics_document,
				{ desc = '[S]earch [D]iagnostics' })
			vim.keymap.set('n', '<leader>sc', builtin.resume, { desc = '[S]earch [C]ontinue' })
		end
	},
	{ 'dylon/vim-antlr' },
	{ 'b0o/schemastore.nvim' },
	-- Global search and replace
	{
		'nvim-pack/nvim-spectre',
		dependencies = 'nvim-lua/plenary.nvim',
		keys = {
			{
				'<leader>sr',
				'<cmd>lua require("spectre").open()<CR>',
				mode = 'n',
				desc = 'Global search and replace'
			} }
	},
	{
		'vonheikemen/fine-cmdline.nvim',
		lazy = false,
		dependencies = { 'MunifTanjim/nui.nvim' },
		keys = {
			{ ':', '<cmd>FineCmdline<CR>', mode = { 'n' }, desc = 'Commandline' },
		},
	},
	{
		'abecodes/tabout.nvim',
		lazy = false,
		opts = {
			tabkey = "", -- key to trigger tabout, set to an empty string to disable
			completion = false, -- if the tabkey is used in a completion pum
			tabouts = {
				{ open = "'", close = "'" },
				{ open = '"', close = '"' },
				{ open = '`', close = '`' },
				{ open = '(', close = ')' },
				{ open = '[', close = ']' },
				{ open = '{', close = '}' }
			},
			exclude = {} -- tabout will ignore these filetypes
		},
		dependencies = { 'nvim-treesitter/nvim-treesitter' }
	},
	{
		"quarto-dev/quarto-nvim",
		dependencies = {
			{
				"jmbuhr/otter.nvim",
				opts = { buffers = { write_to_disk = true } },
			},
			"nvim-treesitter/nvim-treesitter",
		},
	},
	{
		"olimorris/codecompanion.nvim",
		config = true,
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		keys = {

			{ '<leader>cp', '<cmd>CodeCompanionActions<cr>',     mode = 'n', desc = "Open the CodeCompanion Action Pallet." },
			{ '<leader>cc', '<cmd>CodeCompanionChat Toggle<cr>', mode = 'n', desc = "Toggle the CodeCompanion chat buffer." },
		},
		opts = {
			display = {
				action_palette = {
					-- width = 95,
					-- height = 10,
					prompt = "Prompt ", -- Prompt used for interactive LLM calls
					provider = "telescope", -- default|telescope|mini_pick
					opts = {
						show_default_actions = true, -- Show the default actions in the action palette?
						show_default_prompt_library = true, -- Show the default prompt library in the action palette?
					},
				},
			},
			strategies = {
				chat = {
					adapter = "copilot",
				},
				inline = {
					adapter = "copilot",
				},
			},
			adapters = {
				copilot = function()
					return require("codecompanion.adapters").extend("copilot", {
						schema = {
							model = {
								default = "claude-3.7-sonnet",
							},
						},
					})
				end,
			},

		}
	},
	-- { "github/copilot.vim" },
	-- NOTE: Next Step on Your Neovim Journey: Add/Configure additional "plugins" for kickstart
	--       These are some example plugins that I've included in the kickstart repository.
	--       Uncomment any of the lines below to enable them.
	-- require 'kickstart.plugins.autoformat',
	-- require 'kickstart.plugins.debug',

	-- NOTE: The import below automatically adds your own plugins, configuration, etc from `lua/custom/plugins/*.lua`
	--    You can use this folder to prevent any conflicts with this init.lua if you're interested in keeping
	--    up-to-date with whatever is in the kickstart repo.
	--
	-- For additional information see: https://github.com/folke/lazy.nvim#-structuring-your-plugins
	--
	--    An additional note is that if you only copied in the `init.lua`, you can just comment this line
	--    to get rid of the warning telling you that there are not plugins in `lua/custom/plugins/`.
	-- { import = 'custom.plugins' },
}, {})
