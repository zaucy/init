return {
	"folke/todo-comments.nvim",
	dependencies = { "nvim-lua/plenary.nvim" },
	lazy = true,
	opts = {
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
	},
	cmd = { "TodoTelescope" },
	keys = {
		{ "<leader>t", "<cmd>TodoTelescope keywords=TODO,FIX theme=ivy<cr>" },
	},
}
