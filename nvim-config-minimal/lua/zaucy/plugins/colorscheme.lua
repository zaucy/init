require("tokyonight").setup({
	transparent = true,
	style = "night",
	styles = {
		sidebars = "transparent",
		floats = "transparent",
	},
	-- borderless telescope
	on_highlights = function(hl, c)
		local prompt = "#2d3149"
		hl.TelescopeNormal = {
			bg = c.bg_dark,
			fg = c.fg_dark,
		}
		hl.TelescopeBorder = {
			bg = c.bg_dark,
			fg = c.bg_dark,
		}
		hl.TelescopePromptNormal = {
			bg = prompt,
		}
		hl.TelescopePromptBorder = {
			bg = prompt,
			fg = prompt,
		}
		hl.TelescopePromptTitle = {
			bg = prompt,
			fg = prompt,
		}
		hl.TelescopePreviewTitle = {
			bg = c.bg_dark,
			fg = c.bg_dark,
		}
		hl.TelescopeResultsTitle = {
			bg = c.bg_dark,
			fg = c.bg_dark,
		}
	end,
})

require("flow").setup({
	transparent = false, -- Set transparent background.
	fluo_color = "pink", --  Fluo color: pink, yellow, orange, or green.
	mode = "desaturate", -- Intensity of the palette: normal, bright, desaturate, or dark. Notice that dark is ugly!
	aggressive_spell = false, -- Display colors for spell check.
})

require("catppuccin").setup({
	no_bold = true,
})
vim.cmd("colorscheme catppuccin")
