--- @class chat.SetupOptions
--- @field chat_scratch_dir string|nil
--- @field terminal_command string

--- @class chat.ChatTabpageState
--- @field layout snacks.layout|nil
--- @field body snacks.win|nil
--- @field last_focused_win number|nil
--- @field tab_wins snacks.win[]

local M = {
	--- @type chat.SetupOptions
	_opts = {
		terminal_command = "",
	},

	--- @type table<string, number>
	_dir_term_bufs = {},

	--- @type number|nil
	_chat_term_buf = nil,

	--- @type number
	_active_tab_index = 1,

	--- @type table<number, chat.ChatTabpageState>
	_tabpage_state = {},
}

--- @param state chat.ChatTabpageState
local function store_last_focused_win(state)
	local current_win = vim.api.nvim_get_current_win()
	if state.layout then
		for _, win in pairs(state.layout.wins) do
			if current_win == win then
				return false
			end
		end
	end
	state.last_focused_win = current_win
	return true
end

local ns = vim.api.nvim_create_namespace("ZaucyChatTabs")
vim.api.nvim_set_hl(ns, "Cursor", { blend = 100 })

--- @param win snacks.win
local function setup_window_props(win)
	assert(win:win_valid())
	vim.api.nvim_win_set_hl_ns(win.win, ns)
end

local function update_button_state()
	for state_index in ipairs(M._tabpage_state) do
		local state = M._tabpage_state[state_index]
		for i, tab_win in ipairs(state.tab_wins) do
			if tab_win.buf then
				vim.api.nvim_buf_clear_namespace(tab_win.buf, ns, 0, -1)
				if M._active_tab_index == i then
					for line = 0, vim.api.nvim_buf_line_count(tab_win.buf) - 1 do
						vim.api.nvim_buf_add_highlight(tab_win.buf, ns, "Visual", line, 0, -1)
					end
				end
			end
		end
	end
end

local function bind_chat_keys(buf)
	vim.keymap.set({ "t", "v", "n" }, "<Tab>", function()
		M.chat_switch_tab_next()
	end, { buffer = buf })
	vim.keymap.set({ "t", "v", "n" }, "<S-Tab>", function()
		M.chat_switch_tab_prev()
	end, { buffer = buf })
end

local function create_chat_term_buf()
	local orig_cwd = vim.fn.getcwd(0, 0)
	vim.cmd.lcd(M._opts.chat_scratch_dir)
	vim.cmd.terminal(M._opts.terminal_command)
	vim.cmd.lcd(orig_cwd)

	M._chat_term_buf = vim.api.nvim_get_current_buf()
	bind_chat_keys(M._chat_term_buf)
	vim.api.nvim_exec_autocmds("User", {
		pattern = "ZaucyChatTerminalBufCreated",
		data = { terminal_bufnr = M._chat_term_buf },
	})
end

--- @param state chat.ChatTabpageState
local function ensure_chat_term_buf(state)
	if M._active_tab_index == 1 then
		vim.api.nvim_win_call(state.body.win, function()
			state.body.opts.fixbuf = false
			if M._chat_term_buf and vim.api.nvim_buf_is_valid(M._chat_term_buf) then
				vim.api.nvim_win_set_buf(state.body.win, M._chat_term_buf)
			else
				create_chat_term_buf()
			end
			state.body.opts.buf = M._chat_term_buf
			state.body.opts.fixbuf = true
			state.body:update()
		end)
		return
	end

	local cwd = vim.fn.getcwd()

	vim.api.nvim_win_call(state.body.win, function()
		local term_buf = M._dir_term_bufs[cwd]
		state.body.opts.fixbuf = false
		if term_buf == nil or not vim.api.nvim_buf_is_valid(term_buf) then
			vim.cmd.terminal(M._opts.terminal_command)
			term_buf = vim.api.nvim_get_current_buf()
			M._dir_term_bufs[cwd] = term_buf
			bind_chat_keys(term_buf)
			vim.api.nvim_exec_autocmds("User", {
				pattern = "ZaucyChatTerminalBufCreated",
				data = { terminal_bufnr = term_buf },
			})
		else
			vim.api.nvim_win_set_buf(state.body.win, term_buf)
		end

		state.body.opts.buf = term_buf
		state.body.opts.fixbuf = true
		state.body:update()
	end)
end

--- @return chat.ChatTabpageState
local function ensure_layout()
	local tabpage = vim.api.nvim_get_current_tabpage()
	local state = M._tabpage_state[tabpage]

	if state ~= nil and state.layout ~= nil and state.layout:valid() then
		return state
	end

	state = {
		layout = nil,
		body = nil,
		last_focused_win = nil,
		tab_wins = {},
	}
	M._tabpage_state[tabpage] = state

	store_last_focused_win(state)

	local snacks = require("snacks")

	state.body = snacks.win({
		fixbuf = true,
		backdrop = false,
		on_win = setup_window_props,
	})

	state.tab_wins[1] = snacks.win({
		text = {
			"            ",
			"  󰚩 󰭹 chat  ",
			"            ",
		},
		width = 14,
		backdrop = false,
		border = "none",
		on_win = setup_window_props,
		on_buf = function(win)
			bind_chat_keys(win.buf)
			update_button_state()
		end,
	})

	state.tab_wins[2] = snacks.win({
		text = function()
			local cwd = vim.fn.getcwd()
			local full_ws = (" "):rep(#cwd)
			local padding = "  "
			return {
				padding .. full_ws .. padding,
				padding .. cwd .. padding,
				padding .. full_ws .. padding,
			}
		end,
		backdrop = false,
		border = "none",
		on_win = setup_window_props,
		on_buf = function(win)
			bind_chat_keys(win.buf)
			update_button_state()
		end,
	})

	state.layout = snacks.layout.new({
		layout = {
			position = "float",
			col = 0.99999,
			box = "vertical",
			min_width = 90,
			width = 0.4,
			height = 0.999999,
			backdrop = false,
			border = "left",
			resize = true,
			wo = {
				signcolumn = "no",
				wrap = false,
			},
			{
				box = "horizontal",
				min_height = 3,
				max_height = 3,
				height = 3,
				fixed = true,
				{
					win = "chat_btn",
					width = 14,
				},
				{
					win = "cwd_btn",
				},
			},
			{ win = "body" },
		},
		wins = {
			body = state.body,
			chat_btn = state.tab_wins[1],
			cwd_btn = state.tab_wins[2],
		},
	})

	state.body:focus()
	state.body.opts.fixbuf = false
	if M._chat_term_buf and vim.api.nvim_buf_is_valid(M._chat_term_buf) then
		vim.api.nvim_win_set_buf(state.body.win, M._chat_term_buf)
	else
		create_chat_term_buf()
	end
	state.body.opts.buf = M._chat_term_buf
	state.body.opts.fixbuf = true
	state.body:update()

	vim.cmd.startinsert()

	return state
end

--- @return chat.ChatTabpageState|nil
local function get_layout_state()
	local tabpage = vim.api.nvim_get_current_tabpage()
	local state = M._tabpage_state[tabpage]

	if state ~= nil and state.layout ~= nil and state.layout:valid() then
		return state
	end

	return nil
end

function M.chat_show()
	local state = ensure_layout()
	state.layout:unhide()
	state.body:focus()
	vim.cmd.startinsert()
end

function M.chat_hide()
	local state = get_layout_state()
	if state then
		if state.layout then
			state.layout:hide()
			M.chat_defocus()
		end
	end
end

function M.chat_is_visible()
	local state = get_layout_state()
	if not state then
		return false
	end

	---@diagnostic disable-next-line: invisible
	for _, win in ipairs(state.layout:get_wins()) do
		if win:valid() then
			local win_config = vim.api.nvim_win_get_config(win.win)
			-- there doesn't seem to be a "is visible" check on snacks layouts. we assume if any of the layout windows are not hidden then the layout is not hidden
			if not win_config.hide then
				return true
			end
		end
	end

	return false
end

function M.chat_is_focused()
	local state = get_layout_state()
	if not state then
		return false
	end

	local cursor_win = vim.api.nvim_get_current_win()

	---@diagnostic disable-next-line: invisible
	for _, win in ipairs(state.layout:get_wins()) do
		if win:valid() then
			if win.win == cursor_win then
				return true
			end
		end
	end

	return false
end

function M.chat_toggle()
	if M.chat_is_visible() then
		if M.chat_is_focused() then
			M.chat_hide()
		else
			M.chat_focus()
		end
	else
		M.chat_show()
	end
end

function M.chat_focus()
	local state = get_layout_state()
	if not state then
		return
	end

	if M.chat_is_visible() then
		if not M.chat_is_focused() then
			store_last_focused_win(state)
		end

		state.body:focus()
		vim.cmd.startinsert()
	end
end

function M.chat_defocus()
	local state = get_layout_state()
	if not state then
		return
	end

	if not M.chat_is_focused() then
		return
	end

	if state.last_focused_win ~= nil and vim.api.nvim_win_is_valid(state.last_focused_win) then
		vim.api.nvim_set_current_win(state.last_focused_win)
	else
		local all_wins = vim.api.nvim_tabpage_list_wins(0)
		for _, win in ipairs(all_wins) do
			if state.layout then
				for _, layout_win in pairs(state.layout.wins) do
					if layout_win ~= win then
						state.last_focused_win = win
						vim.api.nvim_set_current_win(state.last_focused_win)
						return
					end
				end
			end
		end
	end
end

--- @param index number
function M.chat_switch_tab(index)
	assert(type(index) == "number")
	local state = ensure_layout()
	index = math.floor(index)
	index = ((index - 1) % #state.tab_wins) + 1
	assert(index > 0, "invalid tab index " .. tostring(index))
	assert(index <= #state.tab_wins, "invalid tab index " .. tostring(index))
	M._active_tab_index = index
	update_button_state()
	ensure_chat_term_buf(state)
end

function M.chat_switch_tab_next()
	M.chat_switch_tab(M._active_tab_index + 1)
end

function M.chat_switch_tab_prev()
	M.chat_switch_tab(M._active_tab_index - 1)
end

--- @param opts chat.SetupOptions
function M.setup(opts)
	M._opts = vim.tbl_deep_extend("force", M._opts, opts)
end

return M
