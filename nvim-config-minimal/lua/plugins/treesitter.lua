local function treesitter_config()
	local parsers = require("nvim-treesitter.parsers").get_parser_configs()
	---@diagnostic disable-next-line: inject-field
	parsers.nu = {
		install_info = {
			url = "https://github.com/nushell/tree-sitter-nu.git",
			files = { "src/parser.c" },
			branch = "main",
			requires_generate_from_grammar = false,
		},
	}
	---@diagnostic disable-next-line: inject-field
	parsers.bazelrc = {
		install_info = {
			url = "https://github.com/zaucy/tree-sitter-bazelrc.git",
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
			url = "https://github.com/ecsact-dev/tree-sitter-ecsact.git",
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
		textobjects = {
			select = {
				enable = true,
				lookahead = true,
				keymaps = {
					["af"] = { query = "@function.outer", desc = "Select around function" },
					["if"] = { query = "@function.inner", desc = "Select inside function" },
					["ac"] = { query = "@class.outer", desc = "Select around class" },
					["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
					["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
				},
			},
		},
	})
end

return {
	{
		"nvim-treesitter/nvim-treesitter",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
		},
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
		keys = {
			{ "[c", function() require("treesitter-context").go_to_context(vim.v.count1) end, desc = "Go to context" },
		},
	}
}
