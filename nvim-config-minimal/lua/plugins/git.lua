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
			{ "<leader>gb",  "<cmd>Gitsigns toggle_current_line_blame<cr>", desc = "Toggle Git Blame" },
			{ "]h",          "<cmd>Gitsigns next_hunk<cr>",                 desc = "Next Git Hunk" },
			{ "[h",          "<cmd>Gitsigns prev_hunk<cr>",                 desc = "Previous Git Hunk" },
			{ "<leader>ga",  "<cmd>Gitsigns stage_buffer<cr>",              desc = "Stage Current Buffer" },
			{ "<leader>gd",  "<cmd>Gitsigns diffthis<cr>",                  desc = "View Buffer Diff" },
			{ "<leader>gs",  "<cmd>Telescope git_status<cr>",               desc = "View Status" },
			{ "<leader>grh", "<cmd>Gitsigns reset_hunk<cr>",                desc = "Reset Hunk" },
			{ "<leader>grf", "<cmd>Gitsigns reset_buffer<cr>",              desc = "Reset Whole File" },
			{ "<leader>grb", "<cmd>Gitsigns reset_base<cr>",                desc = "Reset Base" },
			{ "<leader>gh",  "<cmd>Gitsigns preview_hunk_inline<cr>",       desc = "Preview Hunk" },
			{ "<leader>gtd", "<cmd>Gitsigns toggle_deleted<cr>",            desc = "Toggle Show Deleted" },
			{ "<leader>gtm", "<cmd>Gitsigns toggle_linehl<cr>",             desc = "Toggle Show Modified" },
			{ "<leader>gtw", "<cmd>Gitsigns toggle_word_diff<cr>",          desc = "Toggle Show Words Modified" },

			{
				"<leader>gtt",
				function()
					local gitsigns = require('gitsigns')
					local toggle = gitsigns.toggle_deleted()
					gitsigns.toggle_linehl(toggle)
					gitsigns.toggle_word_diff(toggle)
				end,
				desc = "Toggle All"
			},
		},
	}
}
