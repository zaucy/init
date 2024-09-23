return {
	{
		"zaucy/uproject.nvim",
		-- dir = "~/projects/zaucy/uproject.nvim",
		cmd = { "Uproject" },
		lazy = false,
		opts = {},
		keys = {
			{ "<leader>uo", "<cmd>Uproject open<cr>",                                                               desc = "Open Unreal Editor" },
			{ "<leader>ur", "<cmd>Uproject reload show_output<cr>",                                                 desc = "Reload uproject" },
			{ "<leader>up", "<cmd>Uproject play log_cmds=Log\\ Log<cr>",                                            desc = "Play game" },
			{ "<leader>uP", "<cmd>Uproject play debug log_cmds=Log\\ Log<cr>",                                      desc = "Play game (debug)" },
			{ "<leader>ub", "<cmd>Uproject build ignore_junk close_output_on_success type_pattern=Editor wait<cr>", desc = "Build" },
			{ "<leader>uB", "<cmd>Uproject build type_pattern=Editor wait<cr>",                                     desc = "Build (keep open)" },
			{ "<leader>uc", "<cmd>Uproject build_plugins type_pattern=Editor wait<cr>",                             desc = "Build Plugins" },
		},
	},
}
