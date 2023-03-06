local prettier = require("prettier")
local null_ls = require("null-ls")

prettier.setup {
	bin = 'prettier',
	filetypes = {
		"css",
		"graphql",
		"html",
		"javascript",
		"javascriptreact",
		"json",
		"less",
		"markdown",
		"scss",
		"typescript",
		"typescriptreact",
		"yaml",
	},
	["null-ls"] = {
		condition = function()
			return prettier.config_exists()
		end,
		runtime_condition = function(params)
			-- return false to skip running prettier
			return true
		end,
		timeout = 2000,
	}
}
