require("nvim-treesitter").setup({})
vim.g.no_plugin_maps = true

require("treesitter-context").setup({
	max_lines = 3,
	multiwindow = false,
})

vim.keymap.set("n", "[c", function()
	require("treesitter-context").go_to_context(vim.v.count1)
end, { desc = "Go to context" })
