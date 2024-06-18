return {
	{
		"f-person/git-blame.nvim",
		opts = { },
		cmd = {
			"GitBlameToggle",
			"GitBlameEnable",
			"GitBlameDisable",
			"GitBlameOpenFileURL",
			"GitBlameCopyFileURL",
			"GitBlameOpenCommitURL",
		},
		keys = {
			{ "<leader>gbb", "<cmd>GitBlameToggle<cr>", desc = "Toggle Git Blame" },
			{ "<leader>gbo", "<cmd>GitBlameOpenCommitURL<cr>", desc = "Open Git Blame Commit URL" },
		},
	}
}
