return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = { 'nvim-lua/plenary.nvim' },
		opts = function(_, opts)
			opts.pickers = {
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
		end,
		cmd = { "Telescope" },
		keys = {
			{ "<leader>?", "<cmd>Telescope keymaps theme=ivy<cr>", desc = "Keymaps" },
			{ "<leader>'", "<cmd>Telescope resume<cr>", desc = "Open last picker" },
		},
	},
}
