local lsp_setup_handlers = {
	function(server_name)
		local capabilities = require('cmp_nvim_lsp').default_capabilities()
		require("lspconfig")[server_name].setup({
			capabilities = capabilities,
		})
	end,
}

return {
	{
		"neovim/nvim-lspconfig",
	},
	{
		"williamboman/mason.nvim",
		opts = {},
	},
	{
		"williamboman/mason-lspconfig.nvim",
		dependencies = {
			"williamboman/mason.nvim",
			"neovim/nvim-lspconfig",
			"hrsh7th/nvim-cmp",
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			require("mason-lspconfig").setup({
				automatic_installation = true,
				ensure_installed = {
					"lua_ls",
				},
			})
			lsp_setup_handlers[1]("starpls")
			require("mason-lspconfig").setup_handlers(lsp_setup_handlers)
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
		opts = {},
		cmd = {
			"AerialGo",
			"AerialInfo",
			"AerialNext",
			"AerialPrev",
			"AerialOpen",
		},
		keys = {
			{ "<leader>s", "<cmd>Telescope aerial sorting_strategy=descending<cr>", desc = "Goto Symbol" },
			{ "]s",        "<cmd>AerialNext<cr>",                                   desc = "Next Symbol" },
			{ "[s",        "<cmd>AerialPrev<cr>",                                   desc = "Previous Symbol" },
		},
	},
}
