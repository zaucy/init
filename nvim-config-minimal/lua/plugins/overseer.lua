local supress_autoclose = false

vim.api.nvim_create_autocmd({ 'WinLeave' }, {
	callback = function()
		if vim.bo.filetype == "OverseerList" and not supress_autoclose then
			local overseer = require('overseer')
			if require('overseer.window').is_open() then
				overseer.close()
			end
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
							local task_bufnr = task:get_bufnr()
							if not task_bufnr then return end
							require('overseer').close()
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
						overseer.open({ float = true })
						supress_autoclose = false
					end)
				end,
				desc = "Run Task"
			},
		},
	},
}
