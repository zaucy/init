local dap = require("dap")
local dapui = require("dapui")

dap.listeners.after.event_initialized["dapui_config"] = function()
	dapui.open {}
end
dap.listeners.before.event_terminated["dapui_config"] = function()
	dapui.close {}
end
dap.listeners.before.event_exited["dapui_config"] = function()
	dapui.close {}
end

dapui.setup {
	controls = {
		enabled = true,
		element = "breakpoints",
	},
	element_mappings = {
		breakpoints = {
			open = "<CR>",
			toggle = "<TAB>",
		},
	},
	layouts = {
		{
			elements = {
				"scopes",
				"stacks",
				"watches",
			},
			size = 40, -- 40 columns
			position = "left",
		},
		{
			elements = {
				"breakpoints",
				"console",
			},
			size = 0.25, -- 25% of total lines
			position = "bottom",
		},
	}
}

local is_windows = vim.loop.os_uname().sysname == "Windows_NT"

if is_windows then
	dap.adapters.cppdbg = {
		id = 'cppdbg',
		type = 'server',
		port = "4711",
		-- executable = {
		-- 	command = os.getenv("LOCALAPPDATA") ..
		-- 		'\\nvim-data\\mason\\packages\\cpptools\\extension\\debugAdapters\\bin\\OpenDebugAD7.exe',
		-- 	args = { "--server", "--trace" },
		-- 	detached = false,
		-- },
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

	dap.adapters["cppvsdbg"] = {
		type = 'executable',
		command = os.getenv("LOCALAPPDATA") ..
			'\\nvim-data\\mason\\packages\\cpptools\\extension\\debugAdapters\\vsdbg\\bin\\vsdbg.exe',
		args = { "--interpreter=vscode", "--extConfigDir=%USERPROFILE%\\.cppvsdbg\\extensions" },
		detached = false
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

local function convert_cppvsdbg_configurations()
	if dap.configurations.cppvsdbg then
		if not dap.configurations.cppdbg then
			dap.configurations.cppdbg = {}
		end

		for _, conf in ipairs(dap.configurations.cppvsdbg) do
			-- TODO(zaucy): Modify cppvsdbg to be compatible with cppdbg
			table.insert(dap.configurations.cppdbg, conf)
		end

		dap.configurations.cppvsdbg = nil
	end
end

local function debug_continue()
	if dap.session() ~= nil then
		dap.continue()
		return
	end

	dap.configurations = { cppdbg = {} }
	require('dap.ext.vscode').load_launchjs(".vscode/launch.json", {
		cppdbg = { 'cppdbg' },
	})

	convert_cppvsdbg_configurations()

	local items = {}
	for _, cpp_conf in ipairs(dap.configurations.cppdbg) do
		items[#items + 1] = cpp_conf
	end
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
				if choice.type == "cppvsdbg" then
					choice.type = "cppdbg"
				end
				choice.type = "codelldb"

				if choice.stopOnEntry then
					print("stopOnEntry=true does not work. Overriding to false.")
					-- https://github.com/mfussenegger/nvim-dap/issues/787#issuecomment-1382755980
					choice.stopOnEntry = false
				end

				-- choice.MIMode = "lldb"
				-- choice.miDebuggerPath = "lldb"
				if is_windows then
					if choice.program:sub(-string.len(".exe")) ~= ".exe" then
						choice.program = choice.program .. ".exe"
					end
					choice.sourceMap = {
						["."] = "${workspaceFolder}",
					}
				end
				dap.run(choice)
			end
		end
	)

end

vim.keymap.set(
	"n",
	"<leader>d",
	function()
		require('dap.ui.widgets').hover()
	end,
	{ noremap = true, expr = false }
)

for _, mode in ipairs({ "n", "i" }) do
	vim.keymap.set(
		mode,
		"<F5>",
		debug_continue,
		{ noremap = true, expr = false }
	)
	vim.keymap.set(
		mode,
		"<S-F5>",
		debug_reverse_continue,
		{ noremap = true, expr = false }
	)
	vim.keymap.set(
		mode,
		"<F9>",
		function()
			require('dap').toggle_breakpoint()
		end,
		{ noremap = true, expr = false }
	)
	vim.keymap.set(
		mode,
		"<F10>",
		function()
			require('dap').step_over()
		end,
		{ noremap = true, expr = false }
	)
	vim.keymap.set(
		mode,
		"<F11>",
		function()
			require('dap').step_into()
		end,
		{ noremap = true, expr = false }
	)
	vim.keymap.set(
		mode,
		"<F12>",
		function()
			require('dap').step_out()
		end,
		{ noremap = true, expr = false }
	)
end

vim.keymap.set(
	"n",
	"<C-S-D>",
	function()
		require('dapui').toggle {}
	end,
	{ noremap = true, expr = false }
)

vim.keymap.set(
	"i",
	"<C-S-D>",
	function()
		require('dapui').toggle {}
	end,
	{ noremap = true, expr = false }
)
