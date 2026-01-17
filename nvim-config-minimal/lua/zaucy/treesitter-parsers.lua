vim.api.nvim_create_autocmd("User", {
	pattern = "TSUpdate",
	callback = function()
		require("nvim-treesitter.parsers").nu = {
			install_info = {
				url = "https://github.com/nushell/tree-sitter-nu.git",
				files = { "src/parser.c" },
				branch = "main",
				requires_generate_from_grammar = false,
				revision = "",
			},
			tier = 0,
		}
		---@diagnostic disable-next-line: inject-field
		require("nvim-treesitter.parsers").bazelrc = {
			install_info = {
				url = "https://github.com/zaucy/tree-sitter-bazelrc.git",
				files = { "src/parser.c" },
				branch = "main",
				requires_generate_from_grammar = false,
				revision = "",
			},
			tier = 0,
		}
		---@diagnostic disable-next-line: inject-field
		require("nvim-treesitter.parsers").cpp2 = {
			install_info = {
				url = "https://github.com/tsoj/tree-sitter-cpp2.git",
				files = { "src/parser.c", "src/scanner.c" },
				branch = "main",
				generate_requires_npm = false,
				requires_generate_from_grammar = false,
				revision = "",
			},
			tier = 0,
		}
		---@diagnostic disable-next-line: inject-field
		require("nvim-treesitter.parsers").ecsact = {
			install_info = {
				url = "https://github.com/ecsact-dev/tree-sitter-ecsact.git",
				files = { "src/parser.c" },
				branch = "main",
				generate_requires_npm = false,
				requires_generate_from_grammar = false,
				revision = "",
			},
			tier = 0,
		}
	end,
})
