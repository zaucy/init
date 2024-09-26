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
			return table.concat({ unpack(parts, 5) }, ' ')
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
					table.insert(procs, { name = name, pid = pid })
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
					dap.launch({
						type = "executable",
						command = "lldb-dap",
						args = {},
						options = {},
					}, {
						name = "Attach to " .. choice.name,
						type = "lldb-dap",
						request = "attach",
						pid = choice.pid,
						program = choice.name,
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

return {
	"mfussenegger/nvim-dap",
	dependencies = {
		"rcarriga/nvim-dap-ui",
		"nvim-neotest/nvim-nio",
	},
	keys = {
		{ "<leader>da", debug_attach,     desc = "Debug Attach" },
		{ "<leader>dq", debug_disconnect, desc = "Disconnect Debugger" },
		{ "<leader>dd", toggle_debug_ui,  desc = "Debug UI Toggle" },
	},
	config = function()
		local dap = require('dap')
		local dapui = require('dapui')
		dap.adapters.lldb = {
			type = 'executable',
			command = 'lldb-dap',
			name = 'lldb'
		}
		dap.listeners.before.attach.dapui_config = function()
			dapui.open()
		end
		dap.listeners.before.launch.dapui_config = function()
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
	end,
}
