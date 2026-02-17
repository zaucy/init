vim.api.nvim_create_autocmd("User", {
	pattern = "TSUpdate",
	callback = function()
		require("nvim-treesitter.parsers").bazelrc = {
			install_info = {
				url = "https://github.com/zaucy/tree-sitter-bazelrc",
				files = { "src/parser.c" },
				branch = "main",
				requires_generate_from_grammar = false,
				revision = nil,
			},
			tier = 0,
		}
		require("nvim-treesitter.parsers").cpp2 = {
			install_info = {
				url = "https://github.com/tsoj/tree-sitter-cpp2",
				files = { "src/parser.c", "src/scanner.c" },
				branch = "main",
				generate_requires_npm = false,
				requires_generate_from_grammar = false,
				revision = nil,
			},
			tier = 0,
		}
	end,
})
