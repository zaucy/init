-- treesitter is loaded by nvim-treesitter
-- building is handled by build = ":TSUpdate" in vim.pack.add if supported, 
-- but here we just do setup

require("nvim-treesitter.configs").setup({
    -- basic setup if needed, but usually it's handled by after/plugin or similar
    -- if it was just returning the spec in lazy, it might need more here.
})

-- treesitter-textobjects
-- init block from lazy
vim.g.no_plugin_maps = true

-- treesitter-context
require("treesitter-context").setup({
	max_lines = 3,
	multiwindow = false,
})

vim.keymap.set("n", "[c", function()
    require("treesitter-context").go_to_context(vim.v.count1)
end, { desc = "Go to context" })
