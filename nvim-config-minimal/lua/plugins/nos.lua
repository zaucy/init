return {
	{
		"zaucy/nos.nvim",
		lazy = false,
		opts = {},
		config = function()
			require('nos').setup({})
			vim.keymap.set({ 'n', "v" }, 'gs', function()
				vim.opt.operatorfunc = 'v:lua.NosOperatorFunc'
				return 'g@'
			end, { expr = true })
		end,
	}
}
