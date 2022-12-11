local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open {}
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close {}
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close {}
end

dapui.setup {}

local is_windows = vim.loop.os_uname().sysname == "Windows_NT"

if is_windows then
	dap.adapters.cppdbg = {
		id = 'cppdbg',
		type = 'executable',
		command = os.getenv("LOCALAPPDATA") ..
			'\\nvim-data\\mason\\packages\\cpptools\\extension\\debugAdapters\\bin\\OpenDebugAD7.exe',
		options = {
			detached = false,
		},
	}

	dap.adapters.codelldb = {
		type = 'server',
		port = "${port}",
		executable = {
			command = os.getenv("LOCALAPPDATA") ..
				'\\nvim-data\\mason\\packages\\codelldb\\extension\\adapter\\codelldb.exe',
			args = { "--port", "${port}" },
			detached = false,
		},
	}

	dap.adapters["lldb-vscode"] = {
		type = 'server',
		port = "${port}",
		executable = {
			command = os.getenv("ProgramFiles") .. "\\LLVM\\bin\\lldb-vscode.exe",
			args = { "-p", "${port}", "-g" },
			detached = false,
		},
	}

	-- dap.adapters["lldb-vscode"] = {
	-- 	type = 'executable',
	-- 	command = os.getenv("ProgramFiles") .. "\\LLVM\\bin\\lldb-vscode.exe",
	-- 	name = 'lldb-vscode',
	-- 	id = 'lldb-vscode',
	-- 	options = {
	-- 		detached = false,
	-- 	},
	-- }
else

end

local function debug_reverse_continue()
	if dap.session() ~= nil then
		dap.reverse_continue()
		return
	end
end

local function debug_continue()
	if dap.session() ~= nil then
		dap.continue()
		return
	end

	require('dap.ext.vscode').load_launchjs(".vscode/launch.json", {
		cppdbg = { 'c', 'cpp' },
	})

	if dap.configurations.cppdbg then
		print(vim.inspect(dap.configurations.cppdbg))
		local items = {}
		for _, cpp_conf in ipairs(dap.configurations.cppdbg) do
			items[#items + 1] = cpp_conf
		end
		print(vim.inspect(items))
		vim.ui.select(
			items,
			{
				prompt = "Launch",
				format_item = function(item)
					return item.name .. " (" .. item.type .. ")"
				end,
			},
			function(choice)
				if choice then
					-- TODO(zaucy): this type override is weak
					choice.type = "lldb-vscode"
					choice.runInTerminal = true
					choice.stopOnEntry = true
					if is_windows then
						if choice.program:sub(-string.len(".exe")) ~= ".exe" then
							choice.program = choice.program .. ".exe"
						end
					end
					choice.sourceMap = {
						{ "E:/.cache/bazel/output_base/execroot/ecsact_rt_entt", "${workspaceFolder}" },
					}
					dap.run(choice)
				end
			end
		)
	else
		print("No cppdbg configurations")
	end
end

vim.keymap.set(
	"n",
	"<leader>d",
	function()
		require('dap.ui.widgets').hover()
	end,
	{ noremap = true, expr = true }
)

for _, mode in ipairs({ "n", "i" }) do
	vim.keymap.set(
		mode,
		"<F5>",
		debug_continue,
		{ noremap = true, expr = true }
	)
	vim.keymap.set(
		mode,
		"<S-F5>",
		debug_reverse_continue,
		{ noremap = true, expr = true }
	)
	vim.keymap.set(
		mode,
		"<F9>",
		function()
			require('dap').toggle_breakpoint()
		end,
		{ noremap = true, expr = true }
	)
	vim.keymap.set(
		mode,
		"<F10>",
		function()
			require('dap').step_over()
		end,
		{ noremap = true, expr = true }
	)
	vim.keymap.set(
		mode,
		"<F11>",
		function()
			require('dap').step_into()
		end,
		{ noremap = true, expr = true }
	)
	vim.keymap.set(
		mode,
		"<F12>",
		function()
			require('dap').step_out()
		end,
		{ noremap = true, expr = true }
	)
end

vim.keymap.set(
	"n",
	"<C-S-D>",
	function()
		dapui.toggle {}
	end,
	{ noremap = true, expr = true }
)

vim.keymap.set(
	"i",
	"<C-S-D>",
	function()
		dapui.toggle {}
	end,
	{ noremap = true, expr = true }
)
