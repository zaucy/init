return {
	{
		"simonmclean/triptych.nvim",
		dependencies = {
			'nvim-lua/plenary.nvim',
			'nvim-tree/nvim-web-devicons',
		},
		opts = {
			mappings = {
				show_help = { '?', 'g?' },
				jump_to_cwd = '.',
				nav_left = { 'h', '<Left>' },
				nav_right = { 'l', '<Right>', '<CR>' },
				quit = 'q',
				toggle_hidden = 'g.',
			},
			options = {
				border = 'none',
			},
		},
		keys = {
			{ "<leader>-", "<cmd>Triptych<cr>", desc = "Ranger File Exploer" }
		},
	}
}
