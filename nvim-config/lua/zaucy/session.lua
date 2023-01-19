local M = {}
local _session = {
	streamer_mode = false
}

function M.session_state_file_path()
	return vim.fn.stdpath('data') .. '/zaucy/session.json'
end

function M.session_state()
	return _session
end

function M.load_session_state()
	local session_state_json = vim.fn.readfile(M.session_state_file_path(), "B")
	_session = vim.json.decode(session_state_json)
	return _session
end

function M.store_session_state(session)
	if session == nil then
		session = _session
	else
		_session = session
	end
	vim.fn.writefile({ vim.json.encode(session) }, M.session_state_file_path())
end

local session_fp = M.session_state_file_path()
local session_fd = vim.loop.fs_open(session_fp, "r", 0)
if session_fd == nil then
	vim.loop.fs_mkdir(vim.fs.dirname(session_fp), 0)
	M.store_session_state(nil)
end

return M
