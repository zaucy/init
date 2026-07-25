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
		[".*.sch"] = "glsl",
	},
})

vim.api.nvim_create_autocmd("User", {
	pattern = "UprojectBufferCreated",
	callback = function(ev)
		local bufnr = ev.data.bufnr
		local type = ev.data.type
		vim.keymap.set("n", "<C-c>", "<cmd>Uproject cancel<cr>", { buffer = bufnr })
	end,
})

local last_exec_cmds = ""

local function uproject_play_with_last_exec_cmds()
	local async = require("async")
	local task = async.run(function()
		require("uproject").uproject_play(vim.fn.getcwd(), {
			log_cmds = "Log Log",
			exec_cmds = last_exec_cmds,
		})
	end)
	task:raise_on_error()
end

local function uproject_play_with_exec_cmds_prompt()
	vim.ui.input({ prompt = "ExecCmds", default = last_exec_cmds }, function(exec_cmds)
		last_exec_cmds = exec_cmds
		uproject_play_with_last_exec_cmds()
	end)
end

require("uproject").setup({})

vim.keymap.set("n", "<leader>uu", "<cmd>Uproject show_output<cr>", { desc = "Show last output" })
vim.keymap.set("n", "<leader>uo", "<cmd>Uproject open<cr>", { desc = "Open Unreal Editor" })
vim.keymap.set(
	"n",
	"<leader>uO",
	"<cmd>Uproject build use_precompiled wait open<cr>",
	{ desc = "Build and open Unreal Editor" }
)
vim.keymap.set("n", "<leader>uR", "<cmd>Uproject reload show_output<cr>", { desc = "Reload uproject" })
vim.keymap.set("n", "<leader>uL", "<cmd>Uproject unlock_build_dirs <cr>", { desc = "Unlock build dirs" })
vim.keymap.set("n", "<leader>udo", "<cmd>Uproject open debug<cr>", { desc = "Open Unreal Editor (debug)" })
vim.keymap.set("n", "<leader>udp", "<cmd>Uproject play debug<cr>", { desc = "Play game (debug)" })
vim.keymap.set("n", "<leader>uS", "<cmd>Uproject submit<cr>", { desc = "Unreal submit tool" })
vim.keymap.set("n", "<leader>uP", uproject_play_with_exec_cmds_prompt, { desc = "Play" })
vim.keymap.set("n", "<leader>up", uproject_play_with_last_exec_cmds, { desc = "Play (with last exec cmds)" })

vim.keymap.set("n", "<leader>uC", function()
	local async = require("async")
	async.run(function()
		require("uproject").uproject_cook(vim.fn.getcwd(), {
			hide_output = false,
			use_last_target = false,
			iterative_cooking = true,
		})
	end)
end, { desc = "Cook" })

vim.keymap.set("n", "<leader>uc", function()
	local async = require("async")
	async.run(function()
		require("uproject").uproject_cook(vim.fn.getcwd(), {
			hide_output = false,
			use_last_target = true,
			iterative_cooking = true,
		})
	end)
end, { desc = "Cook" })

vim.keymap.set("n", "<leader>uB", function()
	local async = require("async")
	async.run(function()
		require("uproject").uproject_build(vim.fn.getcwd(), {
			wait = false,
			hide_output = false,
			use_last_target = false,
			unlock = "auto",
			use_precompiled = false,
		})
	end)
end, { desc = "Build" })

vim.keymap.set("n", "<leader>ub", function()
	local async = require("async")
	async.run(function()
		require("uproject").uproject_build(vim.fn.getcwd(), {
			wait = false,
			hide_output = false,
			use_last_target = true,
			use_precompiled = false,
			unlock = "auto",
		})
	end)
end, { desc = "Build last (fast)" })

local function render_rounded_border_text(text)
	text = "│ " .. text .. " │"
	local top_text = "╭" .. string.rep("─", #text - 8) .. "╮"
	local bottom_text = "╰" .. string.rep("─", #text - 8) .. "╯"
	return { top_text, text, bottom_text }
end

vim.keymap.set("n", "<leader>uh", function()
	local bazel = require("bazel")

	if bazel.bazel_root(vim.fn.getcwd()) then
		local header_count = 0
		local tabstop = 8
		local bufnr = vim.api.nvim_create_buf(false, true)
		vim.api.nvim_set_option_value("buftype", "nofile", { buf = bufnr })
		vim.api.nvim_buf_set_lines(bufnr, 0, 3, false, render_rounded_border_text(" headers: (loading...)"))
		vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
		vim.api.nvim_set_option_value("tabstop", tabstop, { buf = bufnr })
		vim.api.nvim_win_set_buf(0, bufnr)

		local bazel_cc = require("bazel.cc")
		bazel_cc.list_headers({
			query = "//...",
			deps = true,
			on_message = function(info)
				header_count = header_count + 1
				vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })
				if tabstop < #info.header + 1 then
					tabstop = #info.header + 1
					vim.api.nvim_set_option_value("tabstop", tabstop, { buf = bufnr })
				end
				vim.api.nvim_buf_set_lines(
					bufnr,
					0,
					3,
					false,
					render_rounded_border_text(" headers: " .. tostring(header_count))
				)
				vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, { info.header .. "\t" .. info.target })
				vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
			end,
			on_exit = function(exit_code)
				vim.api.nvim_set_option_value("modifiable", true, { buf = bufnr })

				vim.api.nvim_buf_set_lines(
					bufnr,
					0,
					3,
					false,
					render_rounded_border_text(
						" headers: " .. tostring(header_count) .. " (exit_code=" .. tostring(exit_code) .. ")"
					)
				)
				vim.api.nvim_set_option_value("modifiable", false, { buf = bufnr })
			end,
		})
	else
		local async = require("async")
		async.run(function()
			telescope_unreal_headers()
		end)
	end
end, { desc = "Find headers" })

vim.keymap.set("n", "<leader>ut", function()
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
end, { desc = "Toggle header/source" })

vim.keymap.set("n", "<leader>ui", function()
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
end)

vim.api.nvim_create_autocmd("User", {
	pattern = "UprojectBufferCreated",
	callback = function(ev)
		vim.keymap.set("n", "E", function()
			require("uproject").toggle_error_fold()
		end, { buffer = ev.data.bufnr, desc = "Toggle Error/Warning Fold" })
	end,
})
