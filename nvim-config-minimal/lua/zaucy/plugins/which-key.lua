require("which-key").setup({
	preset = "helix",
	delay = 0,
	icons = {
		separator = "",
		keys = {
			Esc = "󱊷",
		},
	},
})
require("which-key").add({
	{ "<leader>u", group = "unreal" },
	{ "gm", group = "multicursor" },
})
vim.keymap.set("n", "<c-s-w>", function()
	require("which-key").show({
		keys = "<c-w>",
		loop = true,
	})
end)
