return {
	{
		"stevearc/overseer.nvim",
		opts = {
			templates = { "zaucy.build", "zaucy.open", "zaucy.play" },
			task_win = {
				padding = 0,
				border = "rounded",
				win_opts = {
					winblend = 30,
				},
			},
			component_aliases = {
				default = {
					{ "display_duration", detail_level = 1 },
					"on_output_summarize",
					"on_exit_set_status",
					"on_complete_dispose",
				},
			},
			actions = {
				["close task window and open task"] = {
					desc = "Close the overseer window and open the task in the current window",
					--- @param task overseer.Task
					run = function(task)
						if task then
							require('overseer').close()
							task:open_output()
						end
					end,
				},
			},
			task_list = {
				default_detail = 1,
				max_width = { 100, 0.2 },
				min_width = { 40, 0.1 },
				width = nil,
				max_height = { 20, 0.1 },
				min_height = 8,
				height = nil,
				separator = nil,
				direction = "right",
				bindings = {
					["?"] = "ShowHelp",
					["g?"] = "ShowHelp",
					["<CR>"] = "<cmd>OverseerQuickAction close task window and open task<cr>",
					["<C-e>"] = false,
					["o"] = false,
					["<C-v>"] = false,
					["<C-s>"] = false,
					["<C-f>"] = false,
					["<C-q>"] = false,
					["p"] = false,
					["<tab>"] = "TogglePreview",
					["["] = "DecreaseWidth",
					["]"] = "IncreaseWidth",
					["{"] = "PrevTask",
					["}"] = "NextTask",
					["<C-k>"] = "ScrollOutputUp",
					["<C-j>"] = "ScrollOutputDown",
					["<C-Up>"] = "ScrollOutputUp",
					["<C-Down>"] = "ScrollOutputDown",
					["q"] = "Close",
				},
			}
		},
		cmd = {
			"OverseerOpen",
			"OverseerClose",
			"OverseerToggle",
			"OverseerSaveBundle",
			"OverseerLoadBundle",
			"OverseerDeleteBundle",
			"OverseerRunCmd",
			"OverseerRun",
			"OverseerInfo",
			"OverseerBuild",
			"OverseerQuickAction",
			"OverseerTaskAction",
			"OverseerClearCache",
		},
		keys = {
			{ "<leader>oq", "<cmd>OverseerQuickAction<cr>", desc = "Quick Action" },
			{
				"<leader>oo",
				function()
					local overseer = require('overseer')
					if require('overseer.window').is_open() then
						overseer.close()
					else
						overseer.open()
						local sidebar = require('overseer.task_list.sidebar').get()
						if sidebar then
							sidebar:toggle_preview()
						end
					end
				end,
				desc = "Toggle"
			},
			{
				"<leader>or",
				function()
					local overseer = require('overseer')
					--- @param task overseer.Task
					overseer.run_template({}, function(task, err)
						if err then
							vim.notify(err, vim.log.levels.ERROR)
						else
							overseer.open()
							if task then
								local sidebar = require('overseer.task_list.sidebar').get()
								if sidebar then
									sidebar:focus_task_id(task.id)
									sidebar:toggle_preview()
								end
							end
						end
					end)
				end,
				desc = "Run Task"
			},
		},
	},
}
