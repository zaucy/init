require("render-markdown").setup({
	-- debounce = 0,
	-- sign = { enabled = false },
	anti_conceal = { enabled = false },
	-- file_types = { "opencode_output" },
	restart_highlighter = true,
	heading = {
		position = "inline",
		width = "block",
		icons = { "", "", "", "", "", "" },
		border = true,
		above = " ",
		below = "▔",
		left_pad = 0,
		right_pad = 2,
		backgrounds = {
			"Transparent",
			"Transparent",
			"Transparent",
			"Transparent",
			"Transparent",
			"Transparent",
		},
	},
	code = {
		below = "▔",
	},
})
