return {
	{
		"zaucy/uproject.nvim",
		dir = "~/projects/zaucy/uproject.nvim",
		cmd = { "Uproject" },
		lazy = false,
		opts = {},
		keys = {
			{ "<leader>uo", "<cmd>Uproject open<cr>",                                                          desc = "Open Unreal Editor" },
			{ "<leader>ur", "<cmd>Uproject reload show_output<cr>",                                            desc = "Reload uproject" },
			{ "<leader>up", "<cmd>Uproject play<cr>",                                                          desc = "Play game" },
			{ "<leader>ub", "<cmd>Uproject build ignore_junk close_output_on_success type_pattern=Editor<cr>", desc = "Build" },
			{ "<leader>uB", "<cmd>Uproject build type_pattern=Editor<cr>",                                     desc = "Build (keep open)" },
		},
	},
}
