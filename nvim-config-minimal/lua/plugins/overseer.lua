return {
	{
		"stevearc/overseer.nvim",
		dependencies = {
			"zaucy/uproject.nvim", -- for uproject.build
		},

		--- @type overseer.Config
		opts = {
			strategy = {
				"jobstart",
				{ use_terminal = false },
			},
			templates = {
				"vscode",
				"bazel",
				"uproject.build",
				"zaucy.build",
				"zaucy.open",
				"zaucy.play",
			},
			task_win = {
				padding = 0,
				border = "rounded",
				win_opts = {
					winblend = 30,
				},
			},
			component_aliases = {
				default = {
					{ "display_duration",      detail_level = 1 },
					"on_output_summarize",
					"on_exit_set_status",
					{ "on_result_diagnostics", remove_on_restart = true },
					{ "on_complete_notify",    on_change = true,        system = "unfocused" },
				},
			},
			actions = {
				["close task window and open task"] = {
					desc = "Close the overseer window and open the task in the current window",
					--- @param task overseer.Task
					run = function(task)
						if task then
							supress_autoclose = true
							require('overseer').close()
							supress_autoclose = false
							local task_bufnr = task:get_bufnr()
							if not task_bufnr then return end
							vim.api.nvim_win_set_buf(0, task_bufnr)
						end
					end,
				},
				["show task output"] = {
					desc = "Close the overseer window and open the task in the current window",
					--- @param task overseer.Task
					run = function(task)
						if not task then return end
						local task_bufnr = task:get_bufnr()
						if not task_bufnr then return end
						local overseer = require('overseer')
						supress_autoclose = true
						overseer.close()
						vim.api.nvim_win_set_buf(0, task_bufnr)
						overseer.open({ winid = vim.api.nvim_get_current_win() })
						supress_autoclose = false
					end,
				},
			},
			task_list = {
				default_detail = 2,
				max_width = 1,
				min_width = { 40, 0.1 },
				width = nil,
				max_height = 1,
				min_height = 8,
				height = nil,
				-- separator = nil,
				direction = "none",
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
					["R"] = "<cmd>OverseerQuickAction restart<cr>",
					["x"] = "<cmd>OverseerQuickAction stop<cr>",
					["<tab>"] = "<cmd>OverseerQuickAction show task output<cr>",
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
					local tasks = overseer.list_tasks({ })
					if #tasks == 0 then
						vim.notify("No tasks to show")
						return
					end
					local overseer_window = require('overseer.window')
					overseer_window.open({ winid = vim.api.nvim_get_current_win() })
				end,
				desc = "Toggle"
			},
			{
				"<leader>O",
				function()
					local overseer = require('overseer')
					local tasks = overseer.list_tasks({ recent_first = true })
					if vim.tbl_isempty(tasks) then
						vim.notify("No tasks found", vim.log.levels.WARN)
					else
						overseer.run_action(tasks[1], "open")
					end
				end,
				desc = "Open Last Task"
			},
			{
				"<leader>or",
				function()
					local overseer = require('overseer')
					--- @param task overseer.Task
					overseer.run_template({}, function(task, err)
						if err then
							vim.notify(err, vim.log.levels.ERROR)
							return
						end
						if not task then return end
						local task_bufnr = task:get_bufnr()
						if not task_bufnr then return end
						vim.api.nvim_win_set_buf(0, task_bufnr)
					end)
				end,
				desc = "Run Task"
			},
			{
				"<leader>ob",
				function()
					local overseer = require('overseer')
					--- @param task overseer.Task
					overseer.run_template({ tags = { overseer.TAG.BUILD } }, function(task, err)
						if err then
							vim.notify(err, vim.log.levels.ERROR)
							return
						end
						if not task then return end
						local task_bufnr = task:get_bufnr()
						if not task_bufnr then return end
						vim.api.nvim_win_set_buf(0, task_bufnr)
					end)
				end,
				desc = "Run Build Task"
			},
			{
				"<leader>oR",
				function()
					local overseer = require('overseer')
					local tasks = overseer.list_tasks({ recent_first = true })
					if vim.tbl_isempty(tasks) then
						vim.notify("No tasks found", vim.log.levels.WARN)
					else
						overseer.run_action(tasks[1], "restart")
						overseer.run_action(tasks[1], "open")
					end
				end,
				desc = "Run Last Task",
			},
			{
				"<leader>oB",
				function()
					local overseer = require('overseer')
					local tasks = overseer.list_tasks({
						recent_first = true,
						filter = function(task)
							return string.match(task.name, "build") ~= nil
						end,
					})
					if vim.tbl_isempty(tasks) then
						vim.notify("No build tasks found", vim.log.levels.WARN)
					else
						overseer.run_action(tasks[1], "restart")
						overseer.run_action(tasks[1], "open")
					end
				end,
				desc = "Run Last Build Task",
			},
			{
				"<leader>oX",
				function()
					local overseer = require('overseer')
					local tasks = overseer.list_tasks({ recent_first = true })
					if vim.tbl_isempty(tasks) then
						vim.notify("No tasks found", vim.log.levels.WARN)
					else
						overseer.run_action(tasks[1], "stop")
					end
				end,
				desc = "Stop Last Task",
			}
		},
	},
}
