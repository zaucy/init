local oil = require("oil")
local oil_git_status = require("oil-git-status")

oil.setup({
	["g?"] = "actions.show_help",
	["<CR>"] = "actions.select",
	["<C-s>"] = {
		"actions.select",
		opts = { vertical = true },
		desc = "Open the entry in a vertical split",
	},
	["<C-h>"] = {
		"actions.select",
		opts = { horizontal = true },
		desc = "Open the entry in a horizontal split",
	},
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
	["~"] = {
		"actions.cd",
		opts = { scope = "tab", silent = true },
		desc = ":tcd to the current oil directory",
		mode = "n",
	},
})

oil_git_status.setup({
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
})
