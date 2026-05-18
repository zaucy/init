require("render-markdown").setup({
	-- render_modes = { "n", "c", "t", "v", "V" },
	anti_conceal = {
		enabled = true,
	},
	restart_highlighter = true,
	win_options = {
		concealcursor = { rendered = "nvic" },
	},
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
		conceal_delimiters = false,
		border = "thick",
	},
})
