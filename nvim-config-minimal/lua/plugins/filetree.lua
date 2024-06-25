return {
	{
		"stevearc/oil.nvim",
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			default_file_explorer = true,
			skip_confirm_for_simple_edits = true,
			columns = {
				"icon",
				"permissions",
			},
			view_options = {
				show_hidden = false,
			},
		},
		cmd = { "Oil" },
		keys = {
			{ "<leader>e", "<cmd>Oil<cr>",   desc = "Explore Files" },
			{ "<leader>E", "<cmd>Oil .<cr>", desc = "Explore Files (PWD)" },
		},
	}
}
