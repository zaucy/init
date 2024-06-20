local lsp_setup_handlers = {
	function(server_name)
		require("lspconfig")[server_name].setup({})
	end,
	["rust_analyzer"] = function()
		-- mrcjkb/rustaceanvim handles rust analyzer
	end
}

vim.api.nvim_create_autocmd('BufWritePre', {
	callback = function()
		vim.lsp.buf.format({})
	end,
})

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
		},
		config = function()
			require("mason-lspconfig").setup({
				automatic_installation = true,
				ensure_installed = {
					"lua_ls",
				},
			})
			require("mason-lspconfig").setup_handlers(lsp_setup_handlers)
		end,
	},
	{
		"folke/lazydev.nvim",
		ft = "lua",
		init = function()
			vim.g.lazydev_enabled = true
		end,
		opts = {},
	},
	{
		"p00f/clangd_extensions.nvim",
		ft = { "c", "cpp" },
		opts = {},
	},
	{
		"mrcjkb/rustaceanvim",
		ft = "rs",
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
		},
	},
}
