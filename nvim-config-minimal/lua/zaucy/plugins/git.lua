require("gitsigns").setup({
	current_line_blame = true,
	current_line_blame_opts = {
		delay = 0,
	},
})

require("diffview").setup({})

vim.keymap.set("n", "<leader>gb", "<cmd>Gitsigns toggle_current_line_blame<cr>", { desc = "Toggle Git Blame" })
vim.keymap.set("n", "]h", "<cmd>Gitsigns next_hunk<cr>", { desc = "Next Git Hunk" })
vim.keymap.set("n", "[h", "<cmd>Gitsigns prev_hunk<cr>", { desc = "Previous Git Hunk" })
vim.keymap.set("n", "<leader>ga", "<cmd>Gitsigns stage_buffer<cr>", { desc = "Stage Current Buffer" })
vim.keymap.set("n", "<leader>gd", "<cmd>Gitsigns diffthis<cr>", { desc = "View Buffer Diff" })
vim.keymap.set("n", "<leader>gs", "<cmd>Telescope git_status<cr>", { desc = "View Status" })
vim.keymap.set("n", "<leader>grh", "<cmd>Gitsigns reset_hunk<cr>", { desc = "Reset Hunk" })
vim.keymap.set("n", "<leader>grf", "<cmd>Gitsigns reset_buffer<cr>", { desc = "Reset Whole File" })
vim.keymap.set("n", "<leader>grb", "<cmd>Gitsigns reset_base<cr>", { desc = "Reset Base" })
vim.keymap.set("n", "<leader>gh", "<cmd>Gitsigns preview_hunk_inline<cr>", { desc = "Preview Hunk" })
vim.keymap.set("n", "<leader>gtd", "<cmd>Gitsigns toggle_deleted<cr>", { desc = "Toggle Show Deleted" })
vim.keymap.set("n", "<leader>gtm", "<cmd>Gitsigns toggle_linehl<cr>", { desc = "Toggle Show Modified" })
vim.keymap.set("n", "<leader>gtw", "<cmd>Gitsigns toggle_word_diff<cr>", { desc = "Toggle Show Words Modified" })

vim.keymap.set("n", "<leader>gtt", function()
	local gitsigns = require("gitsigns")
	local toggle = gitsigns.toggle_deleted()
	gitsigns.toggle_linehl(toggle)
end, { desc = "Toggle All" })

vim.keymap.set("n", "<C-,>", function()
	vim.notify("file history (back)")
end, { desc = "Diff back" })

vim.keymap.set("n", "<C-.>", function()
	vim.notify("file history (forward)")
end, { desc = "Diff forward" })

vim.keymap.set("n", "<a-left>", "<cmd>DiffviewFileHistory %<cr>", { desc = "File history" })
vim.keymap.set("n", "<leader>gq", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" })
