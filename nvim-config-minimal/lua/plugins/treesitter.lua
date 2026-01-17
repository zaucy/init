return {
	{
		"nvim-treesitter/nvim-treesitter",
		lazy = false,
		build = ":TSUpdate",
		branch = "master",
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("nvim-treesitter.configs").setup({
				ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
				sync_install = false,
				auto_install = true,
				highlight = {
					enable = true,
					additional_vim_regex_highlighting = false,
				},
				indent = { enable = true },
			})
		end,
	},
	{
		branch = "main",
		"nvim-treesitter/nvim-treesitter-textobjects",
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		init = function()
			-- Disable entire built-in ftplugin mappings to avoid conflicts.
			-- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
			vim.g.no_plugin_maps = true
		end,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "VeryLazy",
		opts = {},
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
		keys = {
			{
				"[c",
				function()
					require("treesitter-context").go_to_context(vim.v.count1)
				end,
				desc = "Go to context",
			},
		},
	},
}
