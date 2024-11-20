return {
	{
		"smjonas/live-command.nvim",
		cmd = { "Norm", "Preview" },
		opts = {
			inline_highlighting = false,
			commands = {
				Norm = { cmd = "norm" },
			},
		},
	}
}
