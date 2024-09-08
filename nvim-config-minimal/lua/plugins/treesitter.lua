local function treesitter_config()
	local parsers = require("nvim-treesitter.parsers").get_parser_configs()
	---@diagnostic disable-next-line: inject-field
	parsers.nu = {
		install_info = {
			url = "git@github.com:nushell/tree-sitter-nu.git",
			files = { "src/parser.c" },
			branch = "main",
			requires_generate_from_grammar = false,
		},
	}
	---@diagnostic disable-next-line: inject-field
	parsers.bazelrc = {
		install_info = {
			url = "git@github.com:zaucy/tree-sitter-bazelrc.git",
			files = { "src/parser.c" },
			branch = "main",
			requires_generate_from_grammar = false,
		},
	}
	---@diagnostic disable-next-line: inject-field
	parsers.cpp2 = {
		install_info = {
			url = "https://github.com/tsoj/tree-sitter-cpp2.git",
			files = { "src/parser.c", "src/scanner.c" },
			branch = "main",
			generate_requires_npm = false,
			requires_generate_from_grammar = false,
		},
	}
	---@diagnostic disable-next-line: inject-field
	parsers.ecsact = {
		install_info = {
			url = "git@github.com:ecsact-dev/tree-sitter-ecsact.git",
			files = { "src/parser.c" },
			branch = "main",
			generate_requires_npm = false,
			requires_generate_from_grammar = false,
		},
	}

	---@diagnostic disable-next-line: missing-fields
	require("nvim-treesitter.configs").setup({
		auto_install = false,
		highlight = {
			enable = true,
		},
	})
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		build = ":TSUpdate",
		config = treesitter_config,
	},
	{
		"nvim-treesitter/nvim-treesitter-context",
		event = "VeryLazy",
		opts = {},
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
		},
	}
}
