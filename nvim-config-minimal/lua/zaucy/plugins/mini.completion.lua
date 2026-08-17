require("mini.completion").setup({
	delay = { completion = 100, info = 100, signature = 50 },

	lsp_completion = {
		source_func = "omnifunc",
		auto_setup = true,

		-- A function which takes LSP 'textDocument/completion' response items
		-- (each with `client_id` field for item's server) and word to complete.
		-- Output should be a table of the same nature as input. Common use case
		-- is custom filter/sort. Default: `default_process_items`
		process_items = nil,

		-- A function which takes a snippet as string and inserts it at cursor.
		-- Default: `default_snippet_insert` which tries to use 'mini.snippets'
		-- and falls back to `vim.snippet.expand`.
		snippet_insert = nil,
	},
})
