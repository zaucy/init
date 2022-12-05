vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.termguicolors = true

require("nvim-tree").setup {
	sync_root_with_cwd = true,
	view = {
		side = "right",
		adaptive_size = true,
	},
	actions = {
		expand_all = {
			exclude = {".git"},
		},
	},
	renderer = {
		group_empty = true,
		highlight_opened_files = "all",
	},
	update_focused_file = {
		enable = true,
		update_root = false,
		ignore_list = {},
	},
}
