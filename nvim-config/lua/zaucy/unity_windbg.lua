local _windbg_job = nil
local function start_windbg_unity(label, callback)
	local Job = require 'plenary.job'

	if _windbg_job ~= nil then
		_windbg_job:shutdown(0, 0)
		_windbg_job = nil
	end

	_windbg_job = Job:new {
		command = "WinDbgX",
		skip_validation = true,
		args = { "-g", "-pn", "Unity.exe" },
	}

	_windbg_job:start()
end

vim.api.nvim_create_user_command("WinDbgUnity", start_windbg_unity, {})
