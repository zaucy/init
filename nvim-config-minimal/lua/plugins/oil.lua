local default_hidden = {
	[".git"] = true,
	[".."] = true,
}

local git_ignored = setmetatable({}, {
	__index = function(self, key)
		local proc = vim.system(
			{ "git", "ls-files", "--ignored", "--exclude-standard", "--others", "--directory" },
			{
				cwd = key,
				text = true,
			}
		)
		local result = proc:wait()
		local ret = {}
		if result.code == 0 then
			for line in vim.gsplit(result.stdout, "\n", { plain = true, trimempty = true }) do
				-- Remove trailing slash
				line = line:gsub("/$", "")
				table.insert(ret, line)
			end
		end

		rawset(self, key, ret)
		return ret
	end,
})

local function is_hidden_file(name, _)
	if default_hidden[name] then
		return true
	end
	local dir = require("oil").get_current_dir()
	-- if no local directory (e.g. for ssh connections), always show
	if not dir then
		return false
	end
	dir = vim.fs.normalize(dir)
	-- Check if file is gitignored
	return vim.list_contains(git_ignored[dir], name)
end

vim.api.nvim_create_autocmd({ 'BufReadPre' }, {
	pattern = "oil://*",
	callback = function(ev)
		local dir = vim.fs.normalize(require('oil').get_current_dir())
		rawset(git_ignored, dir, nil)
	end,
})

vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
	pattern = "*/.gitignore",
	callback = function(ev)
		local dir = vim.fs.normalize(vim.fs.dirname(ev.file))
		rawset(git_ignored, dir, nil)
		require('oil.view').rerender_all_oil_buffers({ refetch = false })
	end,
})

vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
	pattern = "oil://*",
	callback = function(ev)
		local dir = vim.fs.normalize(require('oil').get_current_dir())
		rawset(git_ignored, dir, nil)
		require('oil.view').rerender_all_oil_buffers({ refetch = false })
	end,
})

return {
	{
		"stevearc/oil.nvim",
		lazy = false,
		dependencies = { "nvim-tree/nvim-web-devicons" },
		opts = {
			default_file_explorer = true,
			skip_confirm_for_simple_edits = true,
			watch_for_changes = true,
			columns = {
				{
					"icon",
					highlight = "special",
					default_file = "",
					directory = "󰉖",
					add_padding = false,
				},
			},
			view_options = {
				show_hidden = false,
				is_hidden_file = is_hidden_file,
			},
			cleanup_delay_ms = false,
			use_default_keymaps = false,
			keymaps = {
				["g?"] = "actions.show_help",
				["<CR>"] = "actions.select",
				["<C-s>"] = { "actions.select", opts = { vertical = true }, desc = "Open the entry in a vertical split" },
				["<C-h>"] = { "actions.select", opts = { horizontal = true }, desc = "Open the entry in a horizontal split" },
				["<C-t>"] = { "actions.select", opts = { tab = true }, desc = "Open the entry in new tab" },
				["<C-p>"] = "actions.preview",
				["<C-c>"] = "actions.close",
				["<C-l>"] = "actions.refresh",
				["-"] = "actions.parent",
				["_"] = "actions.open_cwd",
				["gs"] = "actions.change_sort",
				["gx"] = "actions.open_external",
				["g."] = "actions.toggle_hidden",
				["g\\"] = "actions.toggle_trash",
				["`"] = { "actions.cd", opts = { silent = true } },
				["~"] = { "actions.cd", opts = { scope = "tab", silent = true }, desc = ":tcd to the current oil directory", mode = "n" },
			},
			win_options = {
				-- for git status
				signcolumn = "yes:2",
			},
		},
		cmd = { "Oil" },
		keys = {
			{ "<leader>e", "<cmd>Oil<cr>",   desc = "Explore Files" },
			{ "<leader>E", "<cmd>Oil .<cr>", desc = "Explore Files (PWD)" },
		},
	},
	{
		"refractalize/oil-git-status.nvim",
		config = {
			show_ignored = false,
			symbols = {
				working_tree = {
					["!"] = "", -- ignored
					["?"] = "",
					["A"] = "",
					["C"] = "",
					["D"] = "",
					["M"] = "",
					["R"] = "",
					["T"] = "",
					["U"] = "U", -- unmerged
					[" "] = " ", -- unmodified
				},
				index = {
					["!"] = "", -- ignored
					["?"] = "",
					["A"] = "",
					["C"] = "",
					["D"] = "",
					["M"] = "",
					["R"] = "",
					["T"] = "",
					["U"] = "U", -- unmerged
					[" "] = " ", -- unmodified
				},
			},
		},
		dependencies = {
			"stevearc/oil.nvim",
		},
	}
}
