return {
	{
		"MeanderingProgrammer/render-markdown.nvim",
		enabled = false, -- after updating to neovim this stopped working
		opts = {
			debounce = 0,
			sign = { enabled = false },
			anti_conceal = {
				enabled = true,
			},
			heading = {
				position = 'inline',
				width = 'block',
				icons = { '', '', '', '', '', '' },
				border = true,
				above = ' ',
				below = '▔',
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
				below = '▔',
			},
		},
	}
}
