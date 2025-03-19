return {
	{
		"zaucy/uproject.nvim",
		dir = "~/projects/zaucy/uproject.nvim",
		cmd = { "Uproject" },
		lazy = false,
		opts = {},
		keys = {
			{ "<leader>uo", "<cmd>Uproject open<cr>",                                   desc = "Open Unreal Editor" },
			{ "<leader>uO", "<cmd>Uproject build  type_pattern=Editor wait open<cr>",   desc = "Build and open Unreal Editor" },
			{ "<leader>ur", "<cmd>Uproject reload show_output<cr>",                     desc = "Reload uproject" },
			{ "<leader>up", "<cmd>Uproject play log_cmds=Log\\ Log<cr>",                desc = "Play game" },
			{ "<leader>uP", "<cmd>Uproject play debug log_cmds=Log\\ Log<cr>",          desc = "Play game (debug)" },
			{ "<leader>uB", "<cmd>Uproject build type_pattern=Editor wait<cr>",         desc = "Build (keep open)" },
			{ "<leader>uc", "<cmd>Uproject build_plugins type_pattern=Editor wait<cr>", desc = "Build Plugins" },
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

						local public_dirs = vim.list_extend(
							vim.fs.find("Public", { type = "dir", path = source_dir, limit = math.huge }),
							vim.fs.find("Public", { type = "dir", path = plugins_dir, limit = math.huge })
						)
						builtin.find_files({
							cwd = engine_dir,
							find_command = {
								"fd",
								"-t", "f", -- files only
								"-E", "*.uplugin",
								"-E", "*.cs",
								"-E", "*.generated.h",
								"-E", "*.cpp",
								"-E", "*.obj",
								"-E", "*.o",
								"-E", "*.svg",
								"-E", "*.uasset",
								"-E", "*.lib",
								"-E", "*.dll",
								"-E", "*.exe",
								"-E", "*.a",
								"-E", "*.pdb",
								"-E", "*.ini",
								"-E", "*.png",
								"-E", "*/Thirdparty/*",
								"-E", "*/ThirdParty/*",
								"--"
							},
							search_dirs = public_dirs,
						})
					end)
				end,
				desc = "List Unreal Modules"
			},
		},
	},
}
