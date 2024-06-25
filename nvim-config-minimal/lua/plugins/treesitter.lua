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
}
