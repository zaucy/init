local function find_public_dirs(path)
	return vim.fs.find(function(name, _)
		return name == "Public"
	end, {
		type = "directory",
		path = path,
		limit = math.huge,
	})
end

return {
	{
		"zaucy/uproject.nvim",
		dependencies = {
			'nvim-lua/plenary.nvim',
			"j-hui/fidget.nvim", -- optional
		},
		cmd = { "Uproject" },
		opts = {},
		keys = {
			{ "<leader>uu", "<cmd>Uproject show_output<cr>",                            desc = "Show last output" },
			{ "<leader>uo", "<cmd>Uproject open<cr>",                                   desc = "Open Unreal Editor" },
			{ "<leader>uO", "<cmd>Uproject build  type_pattern=Editor wait open<cr>",   desc = "Build and open Unreal Editor" },
			{ "<leader>ur", "<cmd>Uproject reload show_output<cr>",                     desc = "Reload uproject" },
			{ "<leader>up", "<cmd>Uproject play log_cmds=Log\\ Log<cr>",                desc = "Play game" },
			{ "<leader>uP", "<cmd>Uproject play debug log_cmds=Log\\ Log<cr>",          desc = "Play game (debug)" },
			{ "<leader>uB", "<cmd>Uproject build type_pattern=Editor wait<cr>",         desc = "Build" },
			{ "<leader>uc", "<cmd>Uproject build_plugins type_pattern=Editor wait<cr>", desc = "Build Plugins" },

			{
				"<leader>ub",
				desc = "Build (fast + hide output)",
				function()
					require('uproject').uproject_build(vim.fn.getcwd(), {
						type_pattern = "Editor",
						wait = true,
						hide_output = true,
						env = {
							-- build systems I use look for this env variable to skip prebuild steps
							"UBT_SKIP_PREBUILD_STEPS=1",
						},
					})
				end
			},

			{
				"<leader>uh",
				function()
					require('uproject').get_project_engine_info(vim.fn.getcwd(), function(info)
						if info == nil then
							vim.notify("cannot find unreal project", vim.log.levels.ERROR)
						end
						local engine_dir = vim.fs.joinpath(info.install_dir, "Engine")
						local source_dir = vim.fs.joinpath(engine_dir, "Source")
						local plugins_dir = vim.fs.joinpath(engine_dir, "Plugins")
						local builtin = require('telescope.builtin')
						local entry_display = require("telescope.pickers.entry_display")
						local finders = require("telescope.finders")
						local make_entry = require("telescope.make_entry")
						local pickers = require("telescope.pickers")
						local sorters = require("telescope.sorters")

						local displayer = entry_display.create({
							separator = " │ ",
							items = {
								{ width = 2 }, -- icon
								{ width = 40 }, -- module name
								{ remaining = true }, -- header path
							},
						})

						local function custom_entry_maker(filepath)
							local entry = make_entry.gen_from_file({})(filepath)
							entry.value = filepath
							entry.filename = filepath
							entry.display = function(entry_inner)
								return displayer({
									"󰦱",
									"<module-name>",
									entry_inner.value,
								})
							end
							return entry
						end

						-- local public_dirs = vim.list_extend(
						-- 	find_public_dirs(source_dir),
						-- 	find_public_dirs(plugins_dir)
						-- )

						local find_command = {
							"fd",
							"--glob", "**/*.h",
							"-t", "f", -- files only
							"-E", "*.generated.h",
							"-E", "*/Thirdparty/*",
							"-E", "*/ThirdParty/*",
						}

						-- for _, dir in ipairs(public_dirs) do
						-- 	table.insert(find_command, "--search-path")
						-- 	table.insert(find_command, dir)
						-- end

						table.insert(find_command, "--")

						pickers.new({}, {
							prompt_title = "Unreal Headers",
							finder = finders.new_oneshot_job(find_command, {
								entry_maker = custom_entry_maker,
								cwd = engine_dir,
							}),
							-- sorter = sorters.get_fuzzy_file(),
							sorter = sorters.get_fzy_sorter(),
						}):find()

						-- builtin.find_files({
						-- 	cwd = engine_dir,
						-- 	find_command = {
						-- 		"fd",
						-- 		"--glob", "**/*.h",
						-- 		"-t", "f", -- files only
						-- 		"-E", "*.generated.h",
						-- 		"-E", "*/Thirdparty/*",
						-- 		"-E", "*/ThirdParty/*",
						-- 		"--"
						-- 	},
						-- 	search_dirs = public_dirs,
						-- })
					end)
				end,
				desc = "Find unreal headers",
			},
		},
	},
}
