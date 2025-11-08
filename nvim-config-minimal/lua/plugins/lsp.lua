return {
	{
		"neovim/nvim-lspconfig",
		init = function()
			vim.lsp.log.set_level("off")
		end,
	},
	{
		"mason-org/mason.nvim",
		opts = {},
	},
	{
		"mason-org/mason-lspconfig.nvim",
		event = "VeryLazy",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			require("mason-lspconfig").setup({
				automatic_enable = true,
				automatic_installation = {
					exclude = { "omnisharp" },
				},
				ensure_installed = {
					"lua_ls",
				},
			})
			vim.lsp.config("*", {
				capabilities = require("cmp_nvim_lsp").default_capabilities(),
			})
		end,
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		init = function()
			vim.g.lazydev_enabled = true
		end,
		opts = {
			library = {
				-- Load luvit types when the `vim.uv` word is found
				{ path = "luvit-meta/library", words = { "vim%.uv" } },
			},
		},
	},
	{ "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
	{
		"p00f/clangd_extensions.nvim",
		ft = { "c", "cpp" },
		opts = {},
	},
	{
		"stevearc/aerial.nvim",
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
		init = function()
			require("telescope").load_extension("aerial")
		end,
		opts = {
			layout = {
				default_direction = "left",
				width = nil,
				resize_to_content = true,
			},
			close_automatic_events = { "unfocus", "switch_buffer", "unsupported" },
			autojump = true,
			close_on_select = true,
			highlight_mode = "none",
			highlight_closest = false,
			highlight_on_hover = false,
			highlight_on_jump = false,
			float = {
				border = "rounded",
				relative = "win",
				override = function(conf, _)
					conf.col = 1
					return conf
				end,
			},
		},
		cmd = {
			"AerialGo",
			"AerialInfo",
			"AerialNext",
			"AerialPrev",
			"AerialOpen",
		},
		keys = {
			{ "<leader>s", "<cmd>AerialOpen<cr>", desc = "Goto Symbol" },
			{ "]s", "<cmd>AerialNext<cr>", desc = "Next Symbol" },
			{ "[s", "<cmd>AerialPrev<cr>", desc = "Previous Symbol" },
		},
	},
	{
		"smjonas/inc-rename.nvim",
		cmd = { "IncRename" },
		opts = {},
	},
}
