return {
	{
		"folke/zen-mode.nvim",
		dependencies = {
			"folke/twilight.nvim",
		},
		opts = {
			window = {
				width = 0.85,
				height = 0.95,
				backdrop = 0.90,
				options = {
					-- signcolumn = "no",
					-- number = false,
					-- relativenumber = false,
					-- cursorline = false,
					-- cursorcolumn = false,
					-- foldcolumn = "0",
					-- list = false,
				},
			},
			plugins = {
				twilight = { enabled = false },
			},
		},
		keys = {
			{
				"<C-w><cr>",
				function()
					require("zen-mode").toggle()
				end,
				desc = "Zen Mode",
			},
		},
	},
}
