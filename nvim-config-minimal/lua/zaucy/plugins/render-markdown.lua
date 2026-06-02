require("render-markdown").setup({
	-- render_modes = { "n", "c", "t", "v", "V" },
	sign = {
		enabled = false,
	},
	anti_conceal = {
		enabled = true,
	},
	restart_highlighter = true,
	win_options = {
		concealcursor = { rendered = "nvic" },
	},
	bullet = {
		border_virtual = false,
	},
	heading = {
		position = "inline",
		width = "block",
		icons = { "", "", "", "", "", "" },
		border = true,
		above = " ",
		below = "▔",
		border_virtual = false,
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
		border_virtual = false,
		border = "thick",
	},
})
