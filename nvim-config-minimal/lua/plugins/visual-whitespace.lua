return {
	"mcauley-penney/visual-whitespace.nvim",
	event = "VeryLazy",
	init = function()
		vim.api.nvim_set_hl(0, "VisualNonText", { fg = "#5D5F71", bg = "#45475a" })
	end,
	opts = {
		space_char = '·',
		tab_char = '\u{ebf9} ',
		nl_char = '↲',
		cr_char = '←',
	},
	keys = {
		{ "<leader>vw", function() require("visual-whitespace").toggle() end, desc = "toggle visual whitespace" }
	},
}
