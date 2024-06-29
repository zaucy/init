return {
	{
		"topaxi/gh-actions.nvim",
		cmd = { "GhActions" },
		opts = {},
	},
	{
		"pwntester/octo.nvim",
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-telescope/telescope.nvim',
			'nvim-tree/nvim-web-devicons',
		},
		cmd = { "Octo" },
		opts = {},
	},
}
