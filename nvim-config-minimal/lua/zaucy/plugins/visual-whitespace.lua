vim.api.nvim_set_hl(0, "VisualNonText", { fg = "#5D5F71", bg = "#45475a" })
require("visual-whitespace").setup({
	space_char = '·',
	tab_char = '\u{ebf9} ',
	nl_char = '↲',
	cr_char = '←',
})
vim.keymap.set("n", "<leader>vw", function() require("visual-whitespace").toggle() end, { desc = "toggle visual whitespace" })
