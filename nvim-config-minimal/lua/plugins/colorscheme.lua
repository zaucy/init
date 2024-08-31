return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		opts = {
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
		},
	},
	{
		"0xstepit/flow.nvim",
		lazy = false,
		priority = 1000,
		opts = {},
		config = function()
			require("flow").setup {
				transparent = false, -- Set transparent background.
				fluo_color = "pink", --  Fluo color: pink, yellow, orange, or green.
				mode = "desaturate", -- Intensity of the palette: normal, bright, desaturate, or dark. Notice that dark is ugly!
				aggressive_spell = false, -- Display colors for spell check.
			}
		end,
	},
	{
		"scottmckendry/cyberdream.nvim",
		lazy = false,
		priority = 1000,
	},
	{
		"catppuccin/nvim",
		name = "catppuccin",
		init = function()
			vim.cmd("colorscheme catppuccin")
		end,
		lazy = false,
		priority = 1000,
		opts = {
			no_bold = true,
		},
	}
}
