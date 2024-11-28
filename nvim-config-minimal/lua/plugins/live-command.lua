return {
	{
		"smjonas/live-command.nvim",
		lazy = false,
		opts = {
			enable_highlighting = true,
			inline_highlighting = true,
			hl_groups = {
				insertion = "DiffAdd",
				deletion = "DiffDelete",
				change = "DiffChange",
			},
			commands = {
				Norm = { cmd = "norm" },
				QG = { cmd = "g" },
			},
		},
	}
}
