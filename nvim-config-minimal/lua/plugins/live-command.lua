return {
	{
		"smjonas/live-command.nvim",
		lazy = false,
		opts = {
			enable_highlighting = true,
			inline_highlighting = true,
			hl_groups = {
				insertion = "DiffAdd",
				deletion = "DiffDelete",
				change = "DiffChange",
			},
			commands = {
				Norm = { cmd = "norm" },
				QG = { cmd = "g" }, -- must be defined before we import vim-abolish
			},
		},
		keys = {
			{
				"gs",
				function()
					local util = require("zaucy.util")
					local cmdline = "g/"
					util.start_cmdline_with_temp_cr({
						initial_cmdline = cmdline,
						initial_cmdline_pos = #cmdline + 1,
						cr_handler = function()
							cmdline = vim.fn.getcmdline()
							if vim.startswith(cmdline, "QG/") then
								return "<cr>"
							else
								cmdline = "QG/" .. cmdline:sub(3) .. "/norm n"
								vim.fn.setcmdline(cmdline, #cmdline + 1)
								return ""
							end
						end,
						cleanup = function()
						end
					})
				end,
			},
			{
				"gs",
				function()
					local util = require("zaucy.util")
					local cmdline = "'<,'>g/"
					util.start_cmdline_with_temp_cr({
						initial_cmdline = cmdline,
						initial_cmdline_pos = #cmdline + 1,
						cr_handler = function()
							cmdline = vim.fn.getcmdline()
							if vim.startswith(cmdline, "'<,'>QG/") then
								return "<cr>"
							else
								cmdline = "'<,'>QG/" .. cmdline:sub(8) .. "/norm n"
								vim.fn.setcmdline(cmdline, #cmdline + 1)
								return ""
							end
						end,
						cleanup = function()
						end
					})
				end,
				mode = "v",
			},
		},
	}
}
