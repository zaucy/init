require("proj").setup({
	hook_dir_changed = true,
})
vim.keymap.set("n", "<leader>p", "<cmd>Telescope proj theme=ivy layout_strategy=horizontal<cr>", { desc = "Open Project" })
