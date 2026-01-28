return {
	{
		"rcarriga/nvim-notify",
		lazy = false,
		config = function()
			---@diagnostic disable-next-line: missing-fields
			require("notify").setup({
				fps = 30,
				top_down = false,
				background_colour = "#2A4137",
				on_open = function(win)
					vim.api.nvim_win_set_config(win, { focusable = false, border = "solid", zindex = 100 })
				end,
			})
			vim.notify = require("notify")
			vim.keymap.set("n", "<Esc>", function()
				require("notify").dismiss({ pending = false, silent = true })
			end, { desc = "dismiss notify popup and clear hlsearch" })

			vim.api.nvim_set_hl(0, "NotifyBackground", { bg = "#282c34" })
		end,
		keys = {
			{ "<leader>n", "<cmd>Telescope notify theme=ivy<cr>", desc = "Notifications" },
		},
	},
}
