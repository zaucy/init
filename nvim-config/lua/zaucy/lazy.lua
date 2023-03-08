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
	----------------------------------------------------------------------------
	-- Color / theme plugins
	{ 'folke/tokyonight.nvim', lazy = false, priority = 1000 },

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

			lsp.setup_nvim_cmp();
			lsp.setup()
		end,
	},
	{
		'nvim-treesitter/nvim-treesitter',
		config = function() require('zaucy.treesitter') end,
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
		},
	},
	'nvim-lua/plenary.nvim',
	'stevearc/dressing.nvim',
	'lewis6991/gitsigns.nvim',
	{
		'goolord/alpha-nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' },
		config = function()
			require('alpha').setup(require('alpha.themes.theta').config)
		end
	},
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons', opt = true }
	},
	'j-hui/fidget.nvim',
	{
		"tpope/vim-scriptease",
		cmd = {
			"Messages", --view messages in quickfix list
			"Verbose", -- view verbose output in preview window.
			"Time", -- measure how long it takes to run some stuff.
		},
	},
	{ "folke/which-key.nvim", config = function() require 'zaucy.which-key' end },

	'mfussenegger/nvim-dap',
	-- { '~/projects/nvim-dap', dev = true },
	'rcarriga/nvim-dap-ui',
	{
		'nvim-neo-tree/neo-tree.nvim',
		lazy = false,
		cmd = { 'Neotree' },
		branch = 'v2.x',
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
		opts = {
			filesystem = {
				hijack_netrw_behavior = "open_default",
				group_empty_dirs = true,
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
})
