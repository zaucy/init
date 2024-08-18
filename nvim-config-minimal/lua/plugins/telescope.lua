local config_dir = "~/projects/zaucy/init/nvim-config-minimal"
local telescope_opts = {
	pickers = {
		builtins = { theme = "ivy" },
		live_grep = { theme = "ivy" },
		vim_options = { theme = "ivy" },
		colorscheme = { theme = "ivy" },
		find_files = { theme = "ivy" },
		git_files = { theme = "ivy" },
		git_stash = { theme = "ivy" },
		git_status = { theme = "ivy" },
		git_commits = { theme = "ivy" },
		git_bcommits = { theme = "ivy" },
		git_branches = { theme = "ivy" },
		git_bcommits_range = { theme = "ivy" },
		buffers = { theme = "ivy" },
		lsp_references = { theme = "ivy" },
		lsp_definitions = { theme = "ivy" },
		lsp_incoming_calls = { theme = "ivy" },
		lsp_outgoing_calls = { theme = "ivy" },
		lsp_implementations = { theme = "ivy" },
		lsp_document_symbols = { theme = "ivy" },
		lsp_type_definitions = { theme = "ivy" },
		lsp_workspace_symbols = { theme = "ivy" },
		lsp_dynamic_workspace_symbols = { theme = "ivy" },
	}
}

return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { 'nvim-lua/plenary.nvim' },
		config = function()
			require("telescope").setup(telescope_opts)
		end,
		cmd = { "Telescope" },
		keys = {
			{ "<leader>?", "<cmd>Telescope keymaps theme=ivy<cr>",                   desc = "Keymaps" },
			{ "<leader>'", "<cmd>Telescope resume<cr>",                              desc = "Open last picker" },
			{ "<leader>/", "<cmd>Telescope live_grep<cr>",                           desc = "Global search" },
			{ "<leader>f", "<cmd>Telescope find_files<cr>",                          desc = "Find files" },
			{ "<leader>b", "<cmd>Telescope buffers<cr>",                             desc = "Find buffers" },
			{ "<leader>c", "<cmd>Telescope find_files cwd=" .. config_dir .. "<cr>", desc = "Config files" },
		},
	},
	{
		"jvgrootveld/telescope-zoxide",
		keys = {
			{ "<leader>z", "<cmd>Telescope zoxide list<cr>", desc = "Zoxide" },
		},
	},
}
