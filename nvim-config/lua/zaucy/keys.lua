local wk = require('which-key')

wk.register({
	gitb = { "<cmd>Gitsign blame_line<CR>", "Git blame current line" },
	qf = { "<cmd>Telescope quickfix<CR>", "Quick Fix" },
	f = {
		name = "file",
		f = { "<cmd>Telescope find_files<CR>", "Find File" },
		s = { "<cmd>Telescope live_grep<CR>", "Search Files" },
		h = { "<cmd>Telescope help_tags<CR>", "Search Help Tags" },
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
	b = {
		name = "Bazel",
		r = { "<cmd>BazelRun<Cr>", "Bazel Run" },
		b = { "<cmd>BazelBuild<Cr>", "Bazel Build" },
		t = { "<cmd>BazelTest<Cr>", "Bazel Test" },
		d = { "<cmd>BazelDebug<Cr>", "Bazel Debug Launch" },
		s = {
			name = "Bazel Source Contexts",
			r = { "<cmd>BazelSourceTargetRun<Cr>", "Bazel Run (target with source)" },
			b = { "<cmd>BazelSourceTargetBuild<Cr>", "Bazel Build (target with source)" },
			t = { "<cmd>BazelSourceTargetTest<Cr>", "Bazel Test (target with source)" },
			d = { "<cmd>BazelSourceTargetDebugLaunch<Cr>", "Bazel Debug Launch (target with source)" },
		},
	}
}, { prefix = "<leader>" })
