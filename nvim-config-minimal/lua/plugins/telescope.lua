local config_dir = "~/projects/zaucy/init/nvim-config-minimal"
local telescope_opts = {
	defaults = {
		path_display = {
			"truncate",
		},
		mappings = {
			i = {
				["<C-a>"] = function(prompt_bufnr)
					local actions = require("telescope.actions")
					local action_state = require("telescope.actions.state")
					local multibuffer = require("multibuffer")
					local picker = action_state.get_current_picker(prompt_bufnr)
					local selections = {}
					for entry in picker.manager:iter() do
						local bufnr = entry.bufnr
						if bufnr == nil then
							bufnr = vim.fn.bufadd(entry.filename)
							vim.fn.bufload(bufnr)
						end
						table.insert(selections, {
							filename = entry.filename,
							bufnr = bufnr,
							start_row = (entry.lnum or 1) - 1,
						})
					end
					actions.close(prompt_bufnr)

					local multibuf = multibuffer.create_multibuf()
					--- @type MultibufAddBufOptions[]
					local add_buf_opts = {}
					for _, selection in ipairs(selections) do
						table.insert(add_buf_opts, {
							buf = selection.bufnr,
							start_row = selection.start_row - 2,
							end_row = selection.start_row + 2,
						})
					end
					multibuffer.multibuf_add_bufs(multibuf, add_buf_opts)
					multibuffer.win_set_multibuf(0, multibuf)
				end,
			},
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

local function setup_telescope_backdrop()
	-- https://github.com/nvim-telescope/telescope.nvim/issues/3020
	vim.api.nvim_create_autocmd("FileType", {
		pattern = "TelescopePrompt",
		callback = function(ctx)
			local backdropName = "TelescopeBackdrop"
			local telescopeBufnr = ctx.buf

			-- `Telescope` does not set a zindex, so it uses the default value
			-- of `nvim_open_win`, which is 50: https://neovim.io/doc/user/api.html#nvim_open_win()
			local telescopeZindex = 50

			local backdropBufnr = vim.api.nvim_create_buf(false, true)
			local winnr = vim.api.nvim_open_win(backdropBufnr, false, {
				relative = "editor",
				border = "none",
				row = 0,
				col = 0,
				width = vim.o.columns,
				height = vim.o.lines,
				focusable = false,
				style = "minimal",
				zindex = telescopeZindex - 1, -- ensure it's below the reference window
			})

			vim.api.nvim_set_hl(0, backdropName, { bg = "#000000", default = true })
			vim.wo[winnr].winhighlight = "Normal:" .. backdropName
			vim.wo[winnr].winblend = 50
			vim.bo[backdropBufnr].buftype = "nofile"

			-- close backdrop when the reference buffer is closed
			vim.api.nvim_create_autocmd({ "WinClosed", "BufLeave" }, {
				once = true,
				buffer = telescopeBufnr,
				callback = function()
					if vim.api.nvim_win_is_valid(winnr) then vim.api.nvim_win_close(winnr, true) end
					if vim.api.nvim_buf_is_valid(backdropBufnr) then
						vim.api.nvim_buf_delete(backdropBufnr, { force = true })
					end
				end,
			})
		end,
	})
end

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
			setup_telescope_backdrop()
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
