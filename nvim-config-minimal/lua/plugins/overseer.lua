local supress_autoclose = false

vim.api.nvim_create_autocmd({ 'WinLeave' }, {
	callback = function()
		if vim.v.exiting ~= nil then return end

		if vim.bo.filetype == "OverseerList" and not supress_autoclose then
			vim.schedule(function()
				local overseer = require('overseer')
				if require('overseer.window').is_open() then
					overseer.close()
				end
			end)
		end
	end,
})

return {
	{
		"zaucy/overseer.nvim",
		branch = "feat/floating-window",
		dependencies = {
			"zaucy/uproject.nvim", -- for uproject.build
		},
		opts = {
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
					"on_output_parse",
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
						overseer.open({ float = true })
						supress_autoclose = false
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
					if require('overseer.window').is_open() then
						overseer.close()
					else
						overseer.open({ float = true })
						local sidebar = require('overseer.task_list.sidebar').get()
						if sidebar then
							sidebar:run_action("show task output")
						end
					end
				end,
				desc = "Toggle"
			},
			{
				"<leader>O",
				function()
					local overseer = require('overseer')
					if not require('overseer.window').is_open() then
						overseer.open({ float = true })
					end
					local sidebar = require('overseer.task_list.sidebar').get()
					if sidebar then
						sidebar:run_action("show task output")
					end
					overseer.close()
				end,
				desc = "Open Last Task"
			},
			{
				"<leader>or",
				function()
					local overseer = require('overseer')
					supress_autoclose = true
					overseer.open({ float = true })
					--- @param task overseer.Task
					overseer.run_template({}, function(task, err)
						if err then
							vim.notify(err, vim.log.levels.ERROR)
							supress_autoclose = false
							return
						end
						if not task then return end
						local sidebar = require('overseer.task_list.sidebar').get()
						if not sidebar then return end
						sidebar:focus_task_id(task.id)
						if not task then return end
						local task_bufnr = task:get_bufnr()
						if not task_bufnr then return end

						overseer.close()
						vim.api.nvim_win_set_buf(0, task_bufnr)
						-- overseer.open({ float = true })
						supress_autoclose = false
					end)
				end,
				desc = "Run Task"
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
