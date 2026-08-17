local function get_procs(cb)
	local is_windows = vim.fn.has('win32') == 1
	local separator = is_windows and ',' or ' \\+'
	local proc = is_windows and 'tasklist' or 'ps'
	local args = is_windows and { '/nh', '/fo', 'csv' } or { 'ah', '-U', os.getenv("USER") }
	local stdout = vim.uv.new_pipe()
	-- local stderr = vim.uv.new_pipe()
	local stdout_str = ""

	local get_pid = function(parts)
		if is_windows then
			return vim.fn.trim(parts[2], '"')
		else
			return parts[1]
		end
	end

	local get_process_name = function(parts)
		if is_windows then
			return vim.fn.trim(parts[1], '"')
		else
			local proc_path = table.concat({ unpack(parts, 5) }, ' ')
			if vim.startswith(proc_path, '/') then
				return vim.fn.fnamemodify(proc_path, ":t")
			else
				return nil
			end
		end
	end

	vim.uv.spawn(proc, {
		stdio = { nil, stdout, nil },
		args = args,
		hide = true,
	}, function(code, _)
		vim.schedule(function()
			if code == 0 then
				local procs = {}
				for _, line in ipairs(vim.fn.split(stdout_str, '\n')) do
					local parts = vim.fn.split(vim.fn.trim(line), separator)
					local pid, name = get_pid(parts), get_process_name(parts)
					pid = tonumber(pid)
					if name ~= nil then
						table.insert(procs, { name = name, pid = pid })
					end
				end
				cb(procs)
			else
				vim.notify("process find failed", vim.log.levels.ERROR)
			end
		end)
	end)

	vim.uv.read_start(stdout, function(err, data)
		if data ~= nil then
			stdout_str = stdout_str .. data
		end
	end)
end

local function debug_attach()
	get_procs(function(procs)
		local largest_name_len = 1
		for _, proc in ipairs(procs) do
			if #proc.name > largest_name_len then
				largest_name_len = #proc.name
			end
		end
		vim.ui.select(
			procs,
			{
				prompt = 'Attach to process',
				format_item = function(item)
					return item.name ..
						string.rep(" ", largest_name_len - #item.name) .. " (pid=" .. tostring(item.pid) .. ")"
				end,
			},
			function(choice)
				if choice ~= nil then
					local dap = require('dap')
					---@diagnostic disable-next-line: missing-parameter
					dap.launch({
						type = "executable",
						command = "lldb-dap-18",
						args = {},
						options = {},
					}, {
						name = "Attach to " .. choice.name,
						type = "lldb-dap",
						request = "attach",
						pid = choice.pid,
						stopOnEntry = false,
						-- program = choice.name,
						initCommands = {
							'process handle -s false -n false SIGWINCH',
						},
						postRunCommands = {
							'settings set target.language c++20',
							'breakpoint set -E c++ -G true',
							'settings set target.source-map /proc/self/cwd ' .. vim.uv.cwd(),
						},
					})
				end
			end
		)
	end)
end

local function toggle_debug_ui()
	require('dapui').toggle()
end

local function debug_disconnect()
	require('dap').disconnect(nil, function()
		require('dapui').close()
	end)
end

local function toggle_breakpoint()
	require('dap').toggle_breakpoint()
end

local function toggle_conditional_breakpoint()
	vim.ui.input({ prompt = 'Condition' }, function(condition)
		require('dap').toggle_breakpoint(condition)
	end)
end

local function halt_process()
	require('dap').repl.execute('process interrupt')
end

local function dap_continue()
	require('dap').continue({ new = false })
end

local function step_over()
	require('dap').step_over()
end

local function step_into()
	require('dap').step_into()
end

local function step_out()
	require('dap').step_out()
end

local dap = require('dap')
local dapui = require('dapui')
dap.adapters.lldb = {
	type = 'executable',
	command = 'lldb-dap-18',
	name = 'lldb'
}
dap.listeners.before.attach.dapui_config = function()
	dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
	dapui.open()
end
dap.listeners.before.event_process.dapui_config = function()
	dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
	dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
	dapui.close()
end

---@diagnostic disable-next-line: missing-fields
dapui.setup({})

require("nvim-dap-virtual-text").setup({})
require("dap-go").setup({})

if vim.g.radnvim then
	local radnvim = require('radnvim')
	toggle_breakpoint = function() radnvim.toggle_breakpoint() end
	toggle_conditional_breakpoint = function()
		vim.ui.input({ prompt = 'Condition' }, function(condition)
			if condition and condition ~= '' then
				radnvim.set_breakpoint(nil, nil, { condition = condition })
			end
		end)
	end
	halt_process = function() radnvim.halt() end
	dap_continue = function() radnvim.run() end
	step_over = function() radnvim.step_over() end
	step_into = function() radnvim.step_into() end
	step_out = function() radnvim.step_out() end
end

local function callstack_picker()
	if vim.g.radnvim then
		local radnvim = require("radnvim")
		local stack = radnvim.get_callstack()
		if #stack == 0 then
			vim.notify("No active call stack (target not stopped)", vim.log.levels.WARN)
			return
		end
		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")
		local conf = require("telescope.config").values
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")

		pickers.new({}, {
			prompt_title = "RAD Call Stack",
			finder = finders.new_table({
				results = stack,
				entry_maker = function(frame)
					local file_tail = frame.file ~= "" and vim.fn.fnamemodify(frame.file, ":t") or frame.module
					local loc = frame.line > 0 and string.format("%s:%d", file_tail, frame.line) or file_tail
					local func = frame.function_name ~= "" and frame.function_name or "???"
					local active_mark = frame.is_active and "▶ " or "  "
					local display = string.format("%s#%-2d 0x%012x  %-28s  %s", active_mark, frame.index, frame.ip, func, loc)

					return {
						value = frame,
						display = display,
						ordinal = string.format("%d %s %s %s", frame.index, func, frame.module, frame.file),
						filename = frame.file ~= "" and frame.file or nil,
						lnum = frame.line > 0 and frame.line or nil,
						col = frame.col > 0 and frame.col or 1,
					}
				end,
			}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr)
				actions.select_default:replace(function()
					actions.close(prompt_bufnr)
					local selection = action_state.get_selected_entry()
					if selection and selection.value then
						radnvim.select_frame(selection.value.unwind_count)
					end
				end)
				return true
			end,
		}):find()
	end
end

local function hover_eval()
	if vim.g.radnvim then
		require("radnvim").hover()
	else
		require("dap.ui.widgets").hover()
	end
end

vim.keymap.set("n", "<leader>da", debug_attach, { desc = "Debug Attach" })
vim.keymap.set("n", "<leader>dq", debug_disconnect, { desc = "Disconnect Debugger" })
vim.keymap.set("n", "<leader>dd", toggle_debug_ui, { desc = "Debug UI Toggle" })
vim.keymap.set("n", "<leader>db", toggle_breakpoint, { desc = "Toggle breakpoint" })
vim.keymap.set("n", "<leader>dB", toggle_conditional_breakpoint, { desc = "Toggle conditional breakpoint" })
vim.keymap.set("n", "<leader>dh", halt_process, { desc = "Halt Process" })
vim.keymap.set("n", "<leader>dc", dap_continue, { desc = "Continue" })
vim.keymap.set("n", "<leader>dcs", callstack_picker, { desc = "Call Stack (Telescope)" })
vim.keymap.set({ "n", "v" }, "<leader>dk", hover_eval, { desc = "Hover Evaluation" })
vim.keymap.set("n", "<leader>d<down>", step_over, { desc = "Step Over" })
vim.keymap.set("n", "<leader>d<right>", step_into, { desc = "Step Into" })
vim.keymap.set("n", "<leader>d<left>", step_out, { desc = "Step Out" })
