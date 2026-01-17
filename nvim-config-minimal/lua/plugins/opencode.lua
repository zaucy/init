return {
	"sudo-tee/opencode.nvim",
	enabled = false,

	---@module 'opencode'
	---@type OpencodeConfig
	---@diagnostic disable: missing-fields
	opts = {
		preferred_picker = "telescope",
		preferred_completion = "nvim-cmp",
		default_global_keymaps = true,
		keymap_prefix = "<leader>l",
		context = {
			current_file = {
				enabled = false,
			},
		},
		ui = {
			output = {
				tools = {
					show_reasoning_output = false,
				},
			},
		},
	},
	---@diagnostic enable: missing-fields
	dependencies = {
		"nvim-lua/plenary.nvim",
		"MeanderingProgrammer/render-markdown.nvim",

		-- Optional, for file mentions and commands completion, pick only one
		-- "saghen/blink.cmp",
		"hrsh7th/nvim-cmp",

		-- Optional, for file mentions picker, pick only one
		"folke/snacks.nvim",
		-- 'nvim-telescope/telescope.nvim',
		-- 'ibhagwan/fzf-lua',
		-- 'nvim_mini/mini.nvim',
	},
}
