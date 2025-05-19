return {
	{
		"rcarriga/nvim-notify",
		lazy = false,
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("notify").setup({
				fps = 20,
				on_open = function(win)
					vim.api.nvim_win_set_config(win, { focusable = false })
				end,
			})
			vim.notify = require("notify")
			vim.keymap.set(
				"n", "<Esc>",
				function() require("notify").dismiss({ pending = false, silent = true }) end,
				{ desc = "dismiss notify popup and clear hlsearch" }
			)
		end,
		keys = {
			{ "<leader>n", "<cmd>Telescope notify theme=ivy<cr>", desc = "Notifications" },
		},
	}
}
