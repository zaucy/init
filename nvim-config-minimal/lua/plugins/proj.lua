return {
	"zaucy/proj.nvim",
	dependencies = {
		'nvim-lua/plenary.nvim',
		'nvim-telescope/telescope.nvim',
		'MunifTanjim/nui.nvim',
	},
	opts = {},
	cmd = { "ProjInfo" },
	keys = {
		{ "<leader>p", "<cmd>Telescope proj theme=ivy layout_strategy=horizontal<cr>", desc = "Open Project" },
	},
}
