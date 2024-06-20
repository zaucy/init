return {
	{
		"stevearc/oil.nvim",
		opts = {},
		cmd = { "Oil" },
		keys = {
			{ "<leader>e", "<cmd>Oil<cr>",   desc = "Explore Files" },
			{ "<leader>E", "<cmd>Oil .<cr>", desc = "Explore Files (PWD)" },
		},
	}
}
