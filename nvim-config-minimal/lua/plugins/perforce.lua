return {
	{
		"ngemily/vim-vp4",
		keys = {
			{ "<leader>va", "<cmd>Vp4Add<cr>",     desc = "Perforce add" },
			{ "<leader>vd", "<cmd>Vp4Delete!<cr>", desc = "Perforce delete" },
			{ "<leader>ve", "<cmd>Vp4Edit<cr>",    desc = "Perforce edit" },
			{ "<leader>vr", "<cmd>Vp4Revert!<cr>", desc = "Perforce revert" },
			{ "<leader>vc", "<cmd>Vp4Reopen<cr>",  desc = "Perforce change changelist" },
			{ "<leader>vq", "<cmd>Vp4Filelog<cr>", desc = "Perforce file log (quickfix)" },
			{ "<leader>v.", "<cmd>Vp4Diff<cr>",    desc = "Perforce file diff" },
		},
	}
}
