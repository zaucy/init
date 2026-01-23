local function find_public_dirs(path)
	return vim.fs.find(function(name, _)
		return name == "Public"
	end, {
		type = "directory",
		path = path,
		limit = math.huge,
	})
end

--- @param filepath string
--- @return boolean
local function is_private_header(filepath)
	local idx = string.find(filepath, "/Private/", 0, true)
	return idx ~= nil
end

--- @param filepath string
--- @return string
local function get_header_module_name(filepath)
	local prefixes = { "/Public/", "/Classes/" }
	for _, prefix in ipairs(prefixes) do
		local idx = string.find(filepath, prefix, 0, true)
		if idx ~= nil then
			local dir = string.sub(filepath, 0, idx - 1)
			local dir_segments = vim.split(dir, "/", { plain = true })
			local module_name = dir_segments[#dir_segments]
			if module_name == "Source" then
				module_name = dir_segments[#dir_segments - 1]
			end
			return module_name
		end
	end

	local filepath_segments = vim.split(filepath, "/", { plain = true })
	return filepath_segments[#filepath_segments - 1]
end

--- @param prefixes string[]
--- @param filepath string
--- @return string
local function get_header_include_string(prefixes, filepath)
	for _, prefix in ipairs(prefixes) do
		local _, idx = string.find(filepath, prefix, 0, true)
		if idx ~= nil then
			return string.sub(filepath, idx + 1)
		end
	end

	return filepath
end

--- @async
local function telescope_unreal_headers()
	local info = require("uproject").get_project_engine_info(vim.fn.getcwd())
	if info == nil then
		vim.notify("cannot find unreal project", vim.log.levels.ERROR)
		return
	end
	local engine_dir = vim.fs.joinpath(info.install_dir, "Engine")
	local source_dir = vim.fs.joinpath(engine_dir, "Source")
	local plugins_dir = vim.fs.joinpath(engine_dir, "Plugins")
	local project_source_dir = vim.fs.joinpath(info.project_dir, "Source")
	local project_plugins_dir = vim.fs.joinpath(info.project_dir, "Plugins")
	local entry_display = require("telescope.pickers.entry_display")
	local finders = require("telescope.finders")
	local make_entry = require("telescope.make_entry")
	local pickers = require("telescope.pickers")
	local sorters = require("telescope.sorters")
	local previewers = require("telescope.previewers")
	local themes = require("telescope.themes")
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	local displayer = entry_display.create({
		separator = " │ ",
		items = {
			{ width = 32 }, -- module name
			{ remaining = true }, -- header path
		},
	})

	--- @param entry {header_info: UnrealHeaderInfo}
	local function entry_display_fn(entry)
		return displayer({
			entry.header_info.module_name,
			entry.header_info.include_string,
		})
	end

	local function custom_entry_maker(filepath)
		filepath = string.gsub(filepath, "\\", "/")

		local entry = make_entry.gen_from_file({})(filepath)
		local private = is_private_header(filepath)
		local module_name = get_header_module_name(filepath)
		local include_string = get_header_include_string({ "/Public/", "/Classes/", "/Source/" }, filepath)
		--- @type UnrealHeaderInfo
		entry.header_info = {
			private = private,
			module_name = module_name,
			include_string = include_string,
		}
		entry.value = filepath
		entry.filename = filepath
		entry.ordinal = module_name .. " " .. include_string
		entry.display = entry_display_fn
		return entry
	end

	local find_command = {
		"fd",
		"--glob",
		"**/*.h",
		"-t",
		"f", -- files only
		"-E",
		"*.generated.h",
		"-E",
		"**/Thirdparty/*",
		"-E",
		"**/ThirdParty/*",
		"-E",
		"**/Binaries/*",
		"-E",
		"**/Private/*",
		"-E",
		"**/Internal/*",
		"-E",
		"**/Intermediate/*",
		"--search-path",
		source_dir,
		"--search-path",
		plugins_dir,
		"--search-path",
		project_source_dir,
		"--search-path",
		project_plugins_dir,
	}

	table.insert(find_command, "--")

	pickers
		.new(themes.get_ivy({}), {
			prompt_title = "Unreal Headers",
			finder = finders.new_oneshot_job(find_command, {
				entry_maker = custom_entry_maker,
				cwd = info.project_dir,
			}),
			previewer = previewers.vim_buffer_cat.new({}),
			sorter = sorters.get_fuzzy_file(),
			attach_mappings = function(prompt_bufnr, map)
				map("i", "<C-y>", function()
					--- @type {filename: string, header_info: UnrealHeaderInfo}
					local entry = action_state.get_selected_entry()
					vim.fn.setreg("m", entry.header_info.module_name)
					vim.fn.setreg("f", entry.filename)
					vim.fn.setreg("i", '#include "' .. entry.header_info.include_string .. '"\n')
					actions.close(prompt_bufnr)
				end)

				return true
			end,
		})
		:find()
end

--- @class UnrealHeaderInfo
--- @field private boolean
--- @field module_name string
--- @field include_string string

vim.filetype.add({
	pattern = {
		["vs_.*.sc"] = "glsl",
		["fs_.*.sc"] = "glsl",
	},
})

return {
	{
		"lewis6991/async.nvim",
		config = function() end,
	},
	{
		"zaucy/uproject.nvim",
		dir = "~/projects/zaucy/uproject.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"lewis6991/async.nvim",
			"j-hui/fidget.nvim", -- optional
		},
		cmd = { "Uproject" },
		opts = {},
		keys = {
			{ "<leader>uu", "<cmd>Uproject show_output<cr>", desc = "Show last output" },
			{ "<leader>uo", "<cmd>Uproject open<cr>", desc = "Open Unreal Editor" },
			{
				"<leader>uO",
				"<cmd>Uproject build use_precompiled wait open<cr>",
				desc = "Build and open Unreal Editor",
			},
			{ "<leader>uR", "<cmd>Uproject reload show_output<cr>", desc = "Reload uproject" },
			{ "<leader>up", "<cmd>Uproject play log_cmds=Log\\ Log<cr>", desc = "Play game" },
			{
				"<leader>uP",
				"<cmd>Uproject build use_precompiled play log_cmds=Log\\ Log<cr>",
				desc = "Build and play game",
			},
			{ "<leader>uC", "<cmd>Uproject clean <cr>", desc = "Clean" },
			{ "<leader>uL", "<cmd>Uproject unlock_build_dirs <cr>", desc = "Unlock build dirs" },
			{
				"<leader>udo",
				"<cmd>Uproject open debug<cr>",
				desc = "Open Unreal Editor (debug)",
			},
			{ "<leader>udp", "<cmd>Uproject play debug<cr>", desc = "Play game (debug)" },

			{ "<leader>uS", "<cmd>Uproject submit<cr>", desc = "Unreal submit tool" },

			{
				"<leader>uB",
				desc = "Build",
				function()
					local async = require("async")
					async.run(function()
						require("uproject").uproject_build(vim.fn.getcwd(), {
							wait = false,
							hide_output = false,
							use_last_target = false,
							unlock = "auto",
							use_precompiled = false,
							-- disable_unity = true,
							no_uba = true,
							no_hot_reload_from_ide = true,
							-- static_analyzer = "default",
						})
					end)
				end,
			},

			{
				"<leader>ub",
				desc = "Build last (fast)",
				function()
					local async = require("async")
					async.run(function()
						require("uproject").uproject_build(vim.fn.getcwd(), {
							wait = false,
							hide_output = false,
							use_last_target = true,
							use_precompiled = false,
							unlock = "auto",
							-- disable_unity = true,
							no_uba = true,
							no_hot_reload_from_ide = true,
							-- static_analyzer = "default",
							-- env = {
							-- build systems I use look for this env variable to skip prebuild steps
							-- "UBT_SKIP_PREBUILD_STEPS=1",
							-- },
						})
					end)
				end,
			},

			{
				"<leader>uh",
				function()
					local async = require("async")
					async.run(function()
						telescope_unreal_headers()
					end)
				end,
				desc = "Find unreal headers",
			},

			{
				"<leader>ut",
				function()
					local util = require("uproject.util")
					local filepath = vim.api.nvim_buf_get_name(0)
					if util.is_header_path(filepath) then
						local source_path = util.get_source_from_header(filepath)
						if source_path then
							vim.cmd.edit(source_path)
						end
					elseif util.is_source_path(filepath) then
						local header_path = util.get_header_from_source(filepath)
						if header_path then
							vim.cmd.edit(header_path)
						end
					else
						vim.cmd("ClangdSwitchSourceHeader")
					end
				end,
				desc = "Toggle header/source",
			},

			{
				"<leader>ui",
				function()
					local ext = vim.fn.expand("%:e")
					local name = vim.fn.expand("%:t:r")

					local lines = {}
					if ext == "cpp" then
						lines = {
							'#include "' .. name .. '.h"',
							"",
							"#include UE_INLINE_GENERATED_CPP_BY_NAME(" .. name .. ")",
							"",
						}
					elseif ext == "h" then
						lines = {
							"#pragma once",
							"",
							'#include "' .. name .. '.generated.h"',
							"",
						}
					else
						return
					end

					vim.api.nvim_put(lines, "l", true, true)
				end,
			},
		},
	},
}
