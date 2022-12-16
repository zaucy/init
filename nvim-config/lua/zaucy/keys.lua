local wk = require('which-key')

wk.register({
	gitb = { "<cmd>Gitsign blame_line<CR>", "Git blame current line" },
	f = {
		name = "file",
		f = { "<cmd>Telescope find_files<CR>", "Find File" },
		s = { "<cmd>Telescope live_grep<CR>", "Search Files" },
		y = { "<cmd>Telescope treesitter<CR>", "Search Current Buffer Symbols (Treesitter)" },
		z = { "<cmd>Telescope zoxide list theme=dropdown<CR>", "Open Directory (Zoxide)" },
		b = { "<cmd>Telescope buffers theme=dropdown<CR>", "Find Buffer" },
		tt = { "<cmd>NvimTreeToggle<CR>", "Toggle File Tree" },
		tf = { "<cmd>NvimTreeFocus<CR>", "Focus File Tree" },
	},
	gh = {
		name = "github",
		p = { "<cmd>Telescope gh pull_request<CR>", "Pull Requests" },
		i = { "<cmd>Telescope gh issues<CR>", "Issues" },
	},
}, { prefix = "<leader>" })
