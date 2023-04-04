local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		'lewis6991/impatient.nvim',
		lazy = false,
		priority = 2000,
		config = function()
			require('impatient')
		end,
	},
	----------------------------------------------------------------------------
	-- Color / theme plugins
	{
		'folke/tokyonight.nvim',
		lazy = false,
		priority = 1000,
		cond = not vim.g.vscode,
		config = function()
			require('zaucy.color')
		end,
	},

	----------------------------------------------------------------------------
	-- File type
	{
		'nathom/filetype.nvim',
		opts = {
			extensions = {
				bazel = "bazel",
				bzl = "bazel",
				ecsact = "ecsact",
				html = "html",
			},
			literal = {
				WORKSPACE = "bazel",
				BUILD = "bazel",
			},
			overrides = {
				ecsact = "ecsact",
			},
		},
	},

	----------------------------------------------------------------------------
	-- LSP and Autocomplete

	{
		'VonHeikemen/lsp-zero.nvim',
		branch = 'v2.x',
		cond = not vim.g.vscode,
		dependencies = {
			-- LSP Support
			{
				'neovim/nvim-lspconfig',
				dir = '~/projects/zaucy/nvim-lspconfig',
				dev = true,
			},
			{
				'williamboman/mason.nvim',
				dir = '~/projects/zaucy/mason.nvim',
				dev = true,
				cmd = 'Mason',
			},
			{ 'williamboman/mason-lspconfig.nvim' },

			-- Autocompletion
			{ 'hrsh7th/nvim-cmp' },
			{ 'hrsh7th/cmp-nvim-lsp' },
			{ 'L3MON4D3/LuaSnip' },
		},
		config = function()
			local lsp = require('lsp-zero').preset({})
			local fmt_augroup = vim.api.nvim_create_augroup("LspFormatting", {})

			vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float)
			vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
			vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
			vim.keymap.set('n', 'gd', vim.lsp.buf.definition)
			vim.keymap.set('n', 'gD', vim.lsp.buf.declaration)
			vim.keymap.set('n', 'gi', vim.lsp.buf.implementation)
			vim.keymap.set('n', 'go', vim.lsp.buf.type_definition)
			vim.keymap.set('n', 'gr', vim.lsp.buf.references)
			vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help)
			vim.keymap.set('n', 'gl', vim.diagnostic.open_float)

			lsp.on_attach(function(client, bufnr)
				lsp.default_keymaps({ buffer = bufnr })

				if client.name == "tsserver" then
					-- formatting is handled by prettier
					if require('prettier').config_exists() then
						client.server_capabilities.documentFormattingProvider = false
					end
				elseif client.supports_method("textDocument/formatting") then
					vim.api.nvim_clear_autocmds({ group = fmt_augroup, buffer = bufnr })
					vim.api.nvim_create_autocmd("BufWritePre", {
						group = fmt_augroup,
						buffer = bufnr,
						callback = function()
							vim.lsp.buf.format({ bufnr = bufnr })
						end,
					})
				end
			end)

			-- Configure lua language server for neovim
			require('lspconfig').lua_ls.setup(lsp.nvim_lua_ls())

			lsp.setup_servers { "ecsact" }

			lsp.setup_nvim_cmp();
			lsp.setup()
		end,
	},
	{
		'nvim-treesitter/nvim-treesitter',
		cond = not vim.g.vscode,
		config = function() require('zaucy.treesitter') end,
	},
	{
		'nvim-treesitter/nvim-treesitter-context',
		opts = {},
		dependencies = {
			'nvim-treesitter/nvim-treesitter',
		},
	},
	'simrat39/rust-tools.nvim',

	----------------------------------------------------------------------------
	-- Telescope
	{
		"nvim-telescope/telescope.nvim",
		cmd = { "Telescope" },
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{ "nvim-telescope/telescope-github.nvim" },
			{ "jvgrootveld/telescope-zoxide" },
		},
	},

	----------------------------------------------------------------------------
	-- Misc
	{
		"folke/zen-mode.nvim",
		cmd = "ZenMode",
		cond = not vim.g.vscode,
		opts = {
			window = {
				backdrop = 1,
				width = 120,
				height = 0.85,
				options = {
					number = false,
					signcolumn = "no",
					cursorline = false,
					cursorcolumn = false,
					foldcolumn = "0",
					relativenumber = false,
					list = false,
					colorcolumn = "0",
				},
			},
			plugins = {
				options = {
					showcmd = false,
				},
			},
		},
	},
	{
		'stevearc/dressing.nvim',
		opts = {},
	},
	{
		'lewis6991/gitsigns.nvim',
		opts = {},
	},
	{
		'nvim-lualine/lualine.nvim',
		cond = not vim.g.vscode,
		opts = {},
		dependencies = { 'nvim-tree/nvim-web-devicons', opt = true },
	},
	{
		'j-hui/fidget.nvim',
		cond = not vim.g.vscode,
	},
	{
		"tpope/vim-scriptease",
		cmd = {
			"Messages", --view messages in quickfix list
			"Verbose", -- view verbose output in preview window.
			"Time", -- measure how long it takes to run some stuff.
		},
	},
	{
		"folke/which-key.nvim",
		config = function()
			require 'zaucy.which-key'
		end,
	},
	{
		'mfussenegger/nvim-dap',
		cond = not vim.g.vscode,
	},
	{
		'rcarriga/nvim-dap-ui',
		cond = not vim.g.vscode,
	},
	{
		'nvim-neo-tree/neo-tree.nvim',
		cond = not vim.g.vscode,
		cmd = { 'Neotree' },
		branch = 'v2.x',
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		opts = {
			filesystem = {
				hijack_netrw_behavior = "open_current",
				group_empty_dirs = true,
				filtered_items = {
					hide_dotfiles = false,
				},
			},
			window = {
				position = 'right',
			},
		},
	},
	{
		'numToStr/Comment.nvim',
		config = function()
			require('Comment').setup()
		end
	},
	{
		'zaucy/bazel.nvim',
		opts = {
			format_on_save = true,
		},
	},
	{
		'akinsho/toggleterm.nvim',
		opts = {
			size = function(term)
				if term.direction == "horizontal" then
					return 15
				elseif term.direction == "vertical" then
					return vim.o.columns * 0.4
				end
			end,
			shell = "nu",
		},
	},
	{ 'sindrets/diffview.nvim', dependencies = 'nvim-lua/plenary.nvim' },
	{
		'TimUntersberger/neogit',
		commit = '7be1e9358aaa617b0391e61952d936203e99fcf0',
		opts = {
			disable_context_highlighting = true,
			commit_popup = {
				kind = "vsplit"
			},
			popup = {
				kind = "split"
			},
		},
		dependencies = {
			'nvim-lua/plenary.nvim',
		},
	},
	{
		'MunifTanjim/prettier.nvim',
		dependencies = {
			'jose-elias-alvarez/null-ls.nvim',
		},
	},
	{
		'stevearc/aerial.nvim',
		opts = {
			layout = {
				width = 40,
				default_direction = "prefer_left",
			},
		},
		dependencies = {
			'stevearc/stickybuf.nvim',
		},
	},
	{
		'stevearc/stickybuf.nvim',
		opts = {},
	},
	{
		'nvim-tree/nvim-web-devicons',
		opts = {},
	},
	{
		'zaucy/nvim-nu',
		dir = '~/projects/zaucy/nvim-nu',
		dev = true,
	},
	{
		'prichrd/netrw.nvim',
		opts = {
			use_devicons = true,
		},
	},
	{
		'rcarriga/nvim-notify',
		config = function()
			require('notify').setup {
				top_down = false,
				max_width = 60,
				render = 'compact',
			}
			vim.notify = require('notify')
		end,
	},
	{
		'euclio/vim-markdown-composer',
		build = 'cargo build --release',
		config = function()
			if vim.loop.os_uname().sysname == "Windows_NT" then
				local firefox = os.getenv("ProgramFiles") .. "/Mozilla Firefox/firefox.exe"
				vim.g.markdown_composer_browser = '"' .. firefox .. '" -url'
			end

			vim.g.markdown_composer_syntax_theme = 'Dark'
		end,
	},
}, {
	lockfile = "~/projects/zaucy/init/nvim-config/lazy-lock.json",
})
