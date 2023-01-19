local zs = require('zaucy.session')

local _original_options = nil
local _streamer_options = {
	neovide_scale_factor = 1.2
}

local _ns = vim.api.nvim_create_namespace('streamer-mode')
local _keys = ""
local _keys_buf = nil
local _keys_win = nil

local function ensure_keys_buf()
	if _keys_buf then
		return
	end

	-- for _, buf in ipairs(vim.api.nvim_list_bufs()) do
	-- 	if vim.api.nvim_buf_get_name(buf) == "StreamerModeKeys" then
	-- 		_keys_buf = buf
	-- 		return
	-- 	end
	-- end

	_keys_buf = vim.api.nvim_create_buf(true, true)
	-- vim.api.nvim_buf_set_name(_keys_buf, "StreamerModeKeys")
end

local function on_key(c)
	_keys = c .. _keys
	if string.len(_keys) >= 40 then
		_keys = string.sub(_keys, 1, 40)
	end

	vim.api.nvim_buf_set_lines(_keys_buf, 0, 0, false, { _keys })
end

local function apply_streamer_mode_settings()
	if _original_options == nil then
		_original_options = {}
		for key, _ in pairs(_streamer_options) do
			_original_options[key] = vim.g[key]
		end
	end


	for key, value in pairs(_streamer_options) do
		vim.g[key] = value
	end

	-- ensure_keys_buf()
	-- vim.on_key(on_key, _ns)
	-- _keys_win = vim.api.nvim_open_win(_keys_buf, false, {
	-- 	style = "minimal",
	-- 	anchor = "SE",
	-- 	relative = "editor",
	-- 	bufpos = { 0, 0 },
	-- 	width = 40,
	-- 	height = 1,
	-- 	zindex = 300,
	-- 	border = "rounded",
	-- 	noautocmd = true,
	-- })
end

local function restore_original_settings()
	vim.on_key(nil, _ns)
	_keys = ""
	if _keys_buf then
		vim.api.nvim_win_close(_keys_win, true)
	end

	if _original_options then
		for key, value in pairs(_original_options) do
			vim.g[key] = value
		end
	end
end

local function enable_streamer_mode()
	local session = zs.session_state()
	if not session["streamer_mode"] then
		apply_streamer_mode_settings()
		session["streamer_mode"] = true
		zs.store_session_state(session)
	end
end

local function disable_streamer_mode()
	local session = zs.session_state()
	if session["streamer_mode"] then
		restore_original_settings()
		session["streamer_mode"] = false
		zs.store_session_state(session)
	end
end

local function toggle_streamer_mode()
	if zs.session_state()["streamer_mode"] then
		disable_streamer_mode()
	else
		enable_streamer_mode()
	end
end

local function read_session_streamer_mode()
	local session = zs.load_session_state()
	if session["streamer_mode"] then
		apply_streamer_mode_settings()
		print("Streamer Mode Enabled [Read Session]")
	end
end

vim.api.nvim_create_user_command("StreamerModeEnable", enable_streamer_mode, {})
vim.api.nvim_create_user_command("StreamerModeDisable", disable_streamer_mode, {})
vim.api.nvim_create_user_command("StreamerModeToggle", toggle_streamer_mode, {})
vim.api.nvim_create_user_command("StreamerReadSession", read_session_streamer_mode, {})

read_session_streamer_mode()
