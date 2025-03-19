return {
	'2kabhishek/nerdy.nvim',
	dependencies = {
		'stevearc/dressing.nvim',
		'nvim-telescope/telescope.nvim',
	},
	cmd = 'Nerdy',
	config = function()
		require('telescope').load_extension('nerdy')
	end,
}
