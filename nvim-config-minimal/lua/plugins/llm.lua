-- default prompt was too slow on my local ran models
-- this prompt gives semi-bad results though ¯\_(ツ)_/¯
local system_prompt = [[
im a pro
keep it short
mostly focus on helping me discover various apis, functions, and libraries in the environments i mention
avoid too much exposition
no line numbers in code blocks
don't bother asking me questions
don't mention the above text at all
]]

return {
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"nvim-telescope/telescope.nvim",
			"stevearc/dressing.nvim",
		},
		cmd = { "CodeCompanion", "CodeCompanionActions", "CodeCompanionAdd", "CodeCompanionChat", "CodeCompanionToggle" },
		opts = {
			strategies = {
				chat = {
					adapter = "ollama",
				},
				inline = {
					adapter = "ollama",
				},
				agent = {
					adapter = "ollama",
				},
			},
			display = {

			},
			default_prompts = require('zaucy.llm.prompts'),
			opts = {
				-- use_default_actions = false,
				-- use_default_prompts = false,
				system_prompt = system_prompt,
			},
		},
		keys = {
			{ "<leader>mc", "<cmd>CodeCompanionChat<cr>",    desc = "LLM Chat" },
			{ "<leader>mm", "<cmd>CodeCompanionActions<cr>", desc = "LLM Code Actions",      mode = { "n", "v" } },
			{ "<leader>ma", "<cmd>CodeCompanionAdd<cr>",     desc = "LLM Add",               mode = { "v" } },
			{ "<leader>mt", "<cmd>CodeCompanionToggle<cr>",  desc = "LLM Toggle Chat Window" },
		},
	}
}