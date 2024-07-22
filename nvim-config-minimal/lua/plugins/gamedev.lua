return {
	{
		"zaucy/uproject.nvim",
		dir = "~/projects/zaucy/uproject.nvim",
		cmd = { "Uproject" },
		lazy = false,
		opts = {},
		keys = {
			{ "<leader>uo", "<cmd>Uproject open<cr>" },
			{ "<leader>ur", "<cmd>Uproject reload show_output<cr>" },
			{ "<leader>up", "<cmd>Uproject play<cr>" },
			{ "<leader>ub", "<cmd>Uproject build ignore_junk close_output_on_success type_pattern=Editor<cr>" },
			{ "<leader>uB", "<cmd>Uproject build type_pattern=Editor<cr>" },
		},
	},
}
