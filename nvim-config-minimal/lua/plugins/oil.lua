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
	-- dotfiles are always considered hidden
	if vim.startswith(name, ".") then
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

vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
	pattern = "*/.gitignore",
	callback = function(ev)
		local dir = vim.fs.normalize(vim.fs.dirname(ev.file))
		rawset(git_ignored, dir, nil)
		require('oil.view').rerender_all_oil_buffers({ refetch = false })
	end,
})

return {
	{
		"stevearc/oil.nvim",
		dir = "~/projects/oil.nvim",
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
				"permissions",
			},
			view_options = {
				show_hidden = false,
				is_hidden_file = is_hidden_file,
			},
		},
		cmd = { "Oil" },
		keys = {
			{ "<leader>e", "<cmd>Oil<cr>",   desc = "Explore Files" },
			{ "<leader>E", "<cmd>Oil .<cr>", desc = "Explore Files (PWD)" },
		},
	}
}
