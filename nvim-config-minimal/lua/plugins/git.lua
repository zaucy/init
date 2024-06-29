return {
	{
		"lewis6991/gitsigns.nvim",
		event = "VeryLazy",
		opts = {
			current_line_blame = true,
			current_line_blame_opts = {
				delay = 0,
			},
		},
		cmd = { "Gitsigns" },
		keys = {
			{ "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle Git Blame" },
			{ "]h",         "<cmd>Gitsigns next_hunk<cr>",                 desc = "Next Git Hunk" },
			{ "[h",         "<cmd>Gitsigns prev_hunk<cr>",                 desc = "Previous Git Hunk" },
		},
	}
}
