require("todo-comments").setup({
	signs = false,
	search = {
		command = "rg",
		args = {
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
		},
		pattern = [[\b(KEYWORDS)(\(.*\)|):]],
	},
})

vim.keymap.set("n", "<leader>t", "<cmd>TodoTelescope keywords=TODO,FIX theme=ivy<cr>")
