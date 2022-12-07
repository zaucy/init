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

if vim.loop.os_uname().sysname == "Windows_NT" then
	dap.adapters.cppdbg = {
		id = 'cppdbg',
		type = 'executable',
		command = os.getenv("LOCALAPPDATA") .. '\\nvim-data\\mason\\packages\\cpptools\\extension\\debugAdapters\\bin\\OpenDebugAD7.exe',
		-- command = os.getenv("LOCALAPPDATA") .. '\\nvim-data\\mason\\packages\\cpptools\\extension\\debugAdapters\\vsdbg\\bin\\vsdbg.exe',
		options = {
			detached = false
		}
	}
else

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
