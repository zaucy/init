return {
	"zaucy/proj.nvim",
	dir = "~/projects/zaucy/proj.nvim",
	dependencies = {
		'nvim-lua/plenary.nvim',
		'nvim-telescope/telescope.nvim',
		'MunifTanjim/nui.nvim',
	},
	opts = {
		hook_dir_changed = true,
	},
	cmd = { "ProjInfo" },
	keys = {
		{ "<leader>p", "<cmd>Telescope proj theme=ivy layout_strategy=horizontal<cr>", desc = "Open Project" },
	},
}
