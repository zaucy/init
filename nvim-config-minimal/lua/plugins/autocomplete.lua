return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 0
		end,
		opts = {
		},
	},
	{
		"smolck/command-completion.nvim",
		opts = {},
	},
}
