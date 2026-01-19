return {
	{
		"zaucy/mcp.nvim",
		-- dir = "~/projects/zaucy/mcp.nvim",
		opts = {},
	},
	{
		"zaucy/gemini.nvim",
		-- dir = "~/projects/zaucy/gemini.nvim",
		build = "bun install -g @google/gemini-cli@nightly",
		dependencies = {
			"zaucy/mcp.nvim",
		},
		opts = {},
	},
}
