local parser_config = require("nvim-treesitter.parsers").get_parser_configs()
parser_config.ecsact = {
	install_info = {
		url = "~/projects/ecsact-dev/tree-sitter-ecsact", -- local path or git repo
		files = { "src/parser.c" },
		-- optional entries:
		branch = "main", -- default branch in case of git repo if different from master
		generate_requires_npm = false, -- if stand-alone parser without npm dependencies
		requires_generate_from_grammar = false, -- if folder contains pre-generated src/parser.c
	},
	filetype = "ecsact", -- if filetype does not match the parser name
}

local ft_to_parser = require "nvim-treesitter.parsers".filetype_to_parsername
ft_to_parser.bazel = "python" -- no tree sitter for bazel. Python is close enough.

require('nvim-treesitter.configs').setup {
	auto_install = true,
	highlight = {
		enable = true,
	},
}

vim.wo.foldmethod = "expr"
vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
vim.wo.foldlevel = 9999
