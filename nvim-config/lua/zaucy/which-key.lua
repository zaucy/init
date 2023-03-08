local wk = require('which-key')

wk.register({
	gitb = { "<cmd>Gitsign blame_line<CR>", "Git blame current line" },
	qf = { "<cmd>Telescope quickfix theme=ivy<CR>", "Quick Fix" },
	tt = { "<cmd>Neotree toggle<CR>", "Tree Toggle" },
	tgs = { "<cmd>Neotree git_status position=float<CR>", "Tree Git Status" },
	f = {
		name = "file",
		f = { "<cmd>Telescope find_files theme=ivy<CR>", "Find File" },
		s = { "<cmd>Telescope live_grep theme=ivy<CR>", "Search Files" },
		h = { "<cmd>Telescope help_tags theme=ivy<CR>", "Search Help Tags" },
		y = { "<cmd>Telescope treesitter theme=ivy<CR>", "Search Current Buffer Symbols (Treesitter)" },
		z = { "<cmd>Telescope zoxide list theme=ivy<CR>", "Open Directory (Zoxide)" },
		b = { "<cmd>Telescope buffers theme=ivy<CR>", "Find Buffer" },
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
		d = { "<cmd>BazelDebug lldb<Cr>", "Bazel Debug Launch" },
		s = {
			name = "Bazel Source Contexts",
			r = { "<cmd>BazelSourceTargetRun<Cr>", "Bazel Run (target with source)" },
			b = { "<cmd>BazelSourceTargetBuild<Cr>", "Bazel Build (target with source)" },
			t = { "<cmd>BazelSourceTargetTest<Cr>", "Bazel Test (target with source)" },
			d = { "<cmd>BazelSourceTargetDebugLaunch lldb<Cr>", "Bazel Debug Launch (target with source)" },
		},
	}
}, { prefix = "<leader>" })
