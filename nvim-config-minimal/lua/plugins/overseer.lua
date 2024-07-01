return {
	{
		"stevearc/overseer.nvim",
		opts = {
			templates = {},
		},
		cmd = {
			"OverseerOpen",
			"OverseerClose",
			"OverseerToggle",
			"OverseerSaveBundle",
			"OverseerLoadBundle",
			"OverseerDeleteBundle",
			"OverseerRunCmd",
			"OverseerRun",
			"OverseerInfo",
			"OverseerBuild",
			"OverseerQuickAction",
			"OverseerTaskAction",
			"OverseerClearCache",
		},
		keys = {
			{ "<leader>o", "<cmd>OverseerToggle!<cr>", desc = "Open Overseer" },
			{ "<leader>r", "<cmd>OverseerRun<cr>",     desc = "Run Overseer Task" },
		},
	},
}
