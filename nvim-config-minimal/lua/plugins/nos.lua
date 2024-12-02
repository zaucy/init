return {
	{
		"zaucy/nos.nvim",
		lazy = false,
		opts = {},
		config = function()
			local nos = require('nos')
			nos.setup({})
			vim.keymap.set({ 'n', "v" }, 'gs', nos.opkeymapfunc, { expr = true })
			vim.keymap.set({ 'n' }, 'gss', nos.bufkeymapfunc)
		end,
	}
}
