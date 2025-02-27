local config_dir = "~/projects/zaucy/init/nvim-config-minimal"
local telescope_opts = {
	defaults = {
		path_display = {
			"truncate",
		},
	},
	extensions = {
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},
	},
	pickers = {
		builtins = { theme = "ivy", path_display = { "truncate" } },
		live_grep = { theme = "ivy", path_display = { "truncate" } },
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
		buffers = { theme = "ivy", path_display = { "truncate" } },
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

local function telescope_fzf_build_cmd()
	if vim.fn.has('win32') == 1 then
		return
		'cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && xcopy build\\Release\\libfzf.dll build\\ /Y'
	else
		return
		'cmake -S . -B build -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release'
	end
end

return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			'nvim-lua/plenary.nvim',
		},
		config = function()
			require('telescope').setup(telescope_opts)
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
		'nvim-telescope/telescope-fzf-native.nvim',
		build = telescope_fzf_build_cmd(),
		dependencies = {
			"nvim-telescope/telescope.nvim",
		},
		config = function()
			require('telescope').load_extension('fzf')
		end,
	},
	{
		"jvgrootveld/telescope-zoxide",
		keys = {
			{ "<leader>z", "<cmd>Telescope zoxide list<cr>", desc = "Zoxide" },
		},
	},
}
