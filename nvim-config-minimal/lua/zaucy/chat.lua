--- @class chat.SetupOptions
--- @field chat_scratch_dir string|nil
--- @field terminal_command string

--- @class chat.ChatTabpageState
--- @field layout chat.Layout|nil
--- @field last_focused_win number|nil
--- @field loading_win number|nil
--- @field loading_timer any|nil

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

	--- @type boolean
	_chat_loading = false,

	--- @type table<string, boolean>
	_dir_loading = {},
}

local ns = vim.api.nvim_create_namespace("ZaucyChatTabs")
vim.api.nvim_set_hl(ns, "Cursor", { blend = 100 })

--- @param state chat.ChatTabpageState
local function store_last_focused_win(state)
	local current_win = vim.api.nvim_get_current_win()
	if state.layout and state.layout:contains_win(current_win) then
		return false
	end
	state.last_focused_win = current_win
	return true
end

--- @param win number
local function setup_window_props(win)
	if vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_set_hl_ns(win, ns)
	end
end

local function update_button_state()
	for state_index in pairs(M._tabpage_state) do
		local state = M._tabpage_state[state_index]
		if state.layout then
			local tab_bufs = { state.layout.bufs.chat_btn, state.layout.bufs.cwd_btn }
			for i, buf in ipairs(tab_bufs) do
				if buf and vim.api.nvim_buf_is_valid(buf) then
					vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
					if M._active_tab_index == i then
						for line = 0, vim.api.nvim_buf_line_count(buf) - 1 do
							vim.api.nvim_buf_add_highlight(buf, ns, "Visual", line, 0, -1)
						end
					end
				end
			end
		end
	end
end

local function bind_chat_keys(buf)
	if not buf or not vim.api.nvim_buf_is_valid(buf) then
		return
	end
	vim.keymap.set({ "t", "v", "n" }, "<Tab>", function()
		M.chat_switch_tab_next()
	end, { buffer = buf })
	vim.keymap.set({ "t", "v", "n" }, "<S-Tab>", function()
		M.chat_switch_tab_prev()
	end, { buffer = buf })
end

local function create_chat_term_buf()
	local orig_cwd = vim.fn.getcwd(0, 0)
	if M._opts.chat_scratch_dir then
		vim.cmd.lcd(M._opts.chat_scratch_dir)
	end
	vim.cmd.terminal(M._opts.terminal_command)
	vim.cmd.lcd(orig_cwd)

	M._chat_term_buf = vim.api.nvim_get_current_buf()
	bind_chat_keys(M._chat_term_buf)
	vim.api.nvim_exec_autocmds("User", {
		pattern = "ZaucyChatTerminalBufCreated",
		data = { terminal_bufnr = M._chat_term_buf },
	})
end

--- @param tabpage number
--- @param state chat.ChatTabpageState
local function ensure_chat_term_buf(tabpage, state)
	assert(type(tabpage) == "number")
	if not state.layout or not state.layout.wins.body or not vim.api.nvim_win_is_valid(state.layout.wins.body) then
		return
	end

	local body_win = state.layout.wins.body

	if M._active_tab_index == 1 then
		vim.api.nvim_win_call(body_win, function()
			-- Disable fixbuf equivalent if needed, though we manipulate buf directly
			if M._chat_term_buf and vim.api.nvim_buf_is_valid(M._chat_term_buf) then
				vim.api.nvim_win_set_buf(body_win, M._chat_term_buf)
			else
				create_chat_term_buf()
				vim.api.nvim_win_set_buf(body_win, M._chat_term_buf)
			end
		end)
		return
	end

	local cwd = vim.fn.getcwd(-1, tabpage)
	cwd = cwd:gsub("\\", "/")

	vim.api.nvim_win_call(body_win, function()
		local term_buf = M._dir_term_bufs[cwd]
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
			vim.api.nvim_win_set_buf(body_win, term_buf)
		end
	end)
end

-- #region Layout Implementation

--- @class chat.Layout
--- @field wins { body: number|nil, chat_btn: number|nil, cwd_btn: number|nil }
--- @field bufs { chat_btn: number|nil, cwd_btn: number|nil }
--- @field opts table
local Layout = {}
Layout.__index = Layout

function Layout.new()
	local self = setmetatable({}, Layout)
	self.wins = {
		body = nil,
		chat_btn = nil,
		cwd_btn = nil,
	}
	self.bufs = {
		chat_btn = nil,
		cwd_btn = nil,
	}
	self.augroup = vim.api.nvim_create_augroup("ZaucyChatLayout", { clear = true })
	return self
end

function Layout:get_geometry()
	local editor_width = vim.o.columns
	local editor_height = vim.o.lines
	local width = math.floor(editor_width * 0.4)
	if width < 90 then
		width = 90
	end
	if width > editor_width then
		width = editor_width
	end

	local col = editor_width - width
	-- Full height usually implies avoiding cmdline, but let's try to match full editor
	-- Snacks used 0.999999 height, essentially full screen.
	local height = editor_height

	return {
		col = col,
		row = 0,
		width = width,
		height = height,
	}
end

function Layout:update_text()
	local geo = self:get_geometry()
	local btn1_width = 13
	local cwd_btn_width = math.max(1, geo.width - (btn1_width + 1))

	if self.bufs.chat_btn and vim.api.nvim_buf_is_valid(self.bufs.chat_btn) then
		-- Width 14.
		-- Center line: "  󰚩 󰭹 chat  "
		-- We assume this fits visually. To ensure background fill, we rely on the highlight covering the text.
		-- If the window is 14 wide and text is shorter, we need padding.
		-- Let's explicitly use a fixed width string if possible, or just ample spaces.
		local lines = {
			string.rep(" ", btn1_width),
			"  󰚩 󰭹 chat   ",
			string.rep(" ", btn1_width),
		}
		vim.api.nvim_set_option_value("modifiable", true, { buf = self.bufs.chat_btn })
		vim.api.nvim_buf_set_lines(self.bufs.chat_btn, 0, -1, false, lines)
		vim.api.nvim_set_option_value("modifiable", false, { buf = self.bufs.chat_btn })
	end

	if self.bufs.cwd_btn and vim.api.nvim_buf_is_valid(self.bufs.cwd_btn) then
		local cwd = vim.fn.getcwd()
		cwd = cwd:gsub("\\", "/")

		-- Center cwd in cwd_btn_width
		local text_len = #cwd
		local padding_total = math.max(0, cwd_btn_width - text_len)
		local pad_left = math.floor(padding_total / 2)
		local pad_right = padding_total - pad_left

		local line_text = string.rep(" ", pad_left) .. cwd .. string.rep(" ", pad_right)
		local empty_line = string.rep(" ", cwd_btn_width)

		local lines = {
			empty_line,
			line_text,
			empty_line,
		}
		vim.api.nvim_set_option_value("modifiable", true, { buf = self.bufs.cwd_btn })
		vim.api.nvim_buf_set_lines(self.bufs.cwd_btn, 0, -1, false, lines)
		vim.api.nvim_set_option_value("modifiable", false, { buf = self.bufs.cwd_btn })
	end
end

function Layout:mount()
	if self:valid() then
		return
	end

	local geo = self:get_geometry()
	local header_height = 3
	local btn1_width = 13

	-- Create Buffers if needed
	if not self.bufs.chat_btn or not vim.api.nvim_buf_is_valid(self.bufs.chat_btn) then
		self.bufs.chat_btn = vim.api.nvim_create_buf(false, true)
		bind_chat_keys(self.bufs.chat_btn)
	end
	if not self.bufs.cwd_btn or not vim.api.nvim_buf_is_valid(self.bufs.cwd_btn) then
		self.bufs.cwd_btn = vim.api.nvim_create_buf(false, true)
		bind_chat_keys(self.bufs.cwd_btn)
	end

	-- Update Text
	self:update_text()
	update_button_state()

	-- Chat Button Window
	self.wins.chat_btn = vim.api.nvim_open_win(self.bufs.chat_btn, false, {
		relative = "editor",
		row = geo.row,
		col = geo.col,
		width = btn1_width,
		height = header_height,
		style = "minimal",
		border = { "", "", "", "", "", "", "", "│" },
		focusable = false,
		zindex = 50,
	})
	setup_window_props(self.wins.chat_btn)
	vim.wo[self.wins.chat_btn].wrap = false

	-- CWD Button Window
	-- Shifted by btn1_width + 1 (border)
	self.wins.cwd_btn = vim.api.nvim_open_win(self.bufs.cwd_btn, false, {
		relative = "editor",
		row = geo.row,
		col = geo.col + btn1_width + 1,
		width = math.max(1, geo.width - (btn1_width + 1)),
		height = header_height,
		style = "minimal",
		border = "none",
		focusable = false,
		zindex = 50,
	})
	setup_window_props(self.wins.cwd_btn)
	vim.wo[self.wins.cwd_btn].wrap = false

	-- Body Window (we don't open with a specific buffer yet, will be set later)
	-- Use a temp buffer initially
	local body_buf = vim.api.nvim_create_buf(false, true)
	self.wins.body = vim.api.nvim_open_win(body_buf, true, {
		relative = "editor",
		row = geo.row + header_height + 1,
		col = geo.col,
		width = math.max(1, geo.width - 1),
		height = math.max(1, geo.height - header_height - 1),
		style = "minimal",
		border = { "", "", "", "", "", "", "", "│" },
		focusable = true,
		zindex = 50,
	})
	setup_window_props(self.wins.body)
	vim.api.nvim_set_option_value("winhighlight", "NormalFloat:Normal", { win = self.wins.body })
	vim.wo[self.wins.body].wrap = false

	-- Resize Autocmd
	vim.api.nvim_create_autocmd("VimResized", {
		group = self.augroup,
		callback = function()
			if self:valid() then
				self:resize()
			end
		end,
	})

	-- Cleanup Autocmd (if any window is closed via :q etc)
	vim.api.nvim_create_autocmd("WinClosed", {
		group = self.augroup,
		pattern = { tostring(self.wins.body), tostring(self.wins.chat_btn), tostring(self.wins.cwd_btn) },
		callback = function()
			vim.schedule(function()
				self:unmount()
			end)
		end,
	})
end

function Layout:resize()
	local geo = self:get_geometry()
	local header_height = 3
	local btn1_width = 13

	if self.wins.chat_btn and vim.api.nvim_win_is_valid(self.wins.chat_btn) then
		vim.api.nvim_win_set_config(self.wins.chat_btn, {
			relative = "editor",
			row = geo.row,
			col = geo.col,
			width = btn1_width,
			height = header_height,
		})
	end

	if self.wins.cwd_btn and vim.api.nvim_win_is_valid(self.wins.cwd_btn) then
		vim.api.nvim_win_set_config(self.wins.cwd_btn, {
			relative = "editor",
			row = geo.row,
			col = geo.col + btn1_width + 1,
			width = math.max(1, geo.width - (btn1_width + 1)),
			height = header_height,
		})
	end

	if self.wins.body and vim.api.nvim_win_is_valid(self.wins.body) then
		vim.api.nvim_win_set_config(self.wins.body, {
			relative = "editor",
			row = geo.row + header_height + 1,
			col = geo.col,
			width = math.max(1, geo.width - 1),
			height = math.max(1, geo.height - header_height - 1),
		})
	end

	self:update_text()
end

function Layout:unmount()
	if self.wins.body and vim.api.nvim_win_is_valid(self.wins.body) then
		vim.api.nvim_win_close(self.wins.body, true)
	end
	if self.wins.chat_btn and vim.api.nvim_win_is_valid(self.wins.chat_btn) then
		vim.api.nvim_win_close(self.wins.chat_btn, true)
	end
	if self.wins.cwd_btn and vim.api.nvim_win_is_valid(self.wins.cwd_btn) then
		vim.api.nvim_win_close(self.wins.cwd_btn, true)
	end
	self.wins = { body = nil, chat_btn = nil, cwd_btn = nil }
	vim.api.nvim_clear_autocmds({ group = self.augroup })
end

function Layout:valid()
	return self.wins.body and vim.api.nvim_win_is_valid(self.wins.body)
end

function Layout:contains_win(win)
	for _, w in pairs(self.wins) do
		if w == win then
			return true
		end
	end
	return false
end

function Layout:get_wins()
	local wins = {}
	if self.wins.body then
		table.insert(wins, self.wins.body)
	end
	if self.wins.chat_btn then
		table.insert(wins, self.wins.chat_btn)
	end
	if self.wins.cwd_btn then
		table.insert(wins, self.wins.cwd_btn)
	end
	return wins
end

-- #endregion

--- @return chat.ChatTabpageState
local function ensure_layout()
	local tabpage = vim.api.nvim_get_current_tabpage()
	local state = M._tabpage_state[tabpage]

	if state ~= nil and state.layout ~= nil and state.layout:valid() then
		return state
	end

	state = {
		layout = nil,
		last_focused_win = nil,
		loading_win = nil,
	}
	M._tabpage_state[tabpage] = state

	store_last_focused_win(state)

	state.layout = Layout.new()
	state.layout:mount()

	-- Initialize content
	ensure_chat_term_buf(tabpage, state)

	vim.cmd.startinsert()
	M._update_loading_overlay()

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

--- @param state chat.ChatTabpageState
local function _show_loading_overlay(state)
	if state.loading_win and vim.api.nvim_win_is_valid(state.loading_win) then
		return
	end

	if not state.layout or not state.layout.wins.body or not vim.api.nvim_win_is_valid(state.layout.wins.body) then
		return
	end

	local body_win = state.layout.wins.body
	local frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
	local frame_idx = 1

	local config = vim.api.nvim_win_get_config(body_win)

	local function get_spinner_text()
		local spin = frames[frame_idx]
		frame_idx = (frame_idx % #frames) + 1

		local h = config.height
		local w = config.width
		local lines = {}
		local mid = math.floor(h / 2)

		for i = 1, h do
			if i == mid then
				local padding_len = math.max(0, math.floor((w - #spin) / 2))
				local padding = string.rep(" ", padding_len)
				table.insert(lines, padding .. spin .. padding)
			else
				table.insert(lines, string.rep(" ", w))
			end
		end
		return lines
	end

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, false, {
		relative = "win",
		win = body_win,
		row = 0,
		col = 0,
		width = config.width,
		height = config.height,
		zindex = (config.zindex or 50) + 10,
		style = "minimal",
		border = "none",
		focusable = false,
	})
	state.loading_win = win

	vim.api.nvim_win_set_option(win, "winblend", 80)
	setup_window_props(win)

	local uv = vim.uv or vim.loop
	state.loading_timer = uv.new_timer()
	state.loading_timer:start(
		0,
		80,
		vim.schedule_wrap(function()
			if state.loading_win and vim.api.nvim_win_is_valid(state.loading_win) then
				if vim.api.nvim_win_is_valid(body_win) then
					local new_config = vim.api.nvim_win_get_config(body_win)
					local my_config = vim.api.nvim_win_get_config(state.loading_win)

					-- Update size if body changed
					if new_config.width ~= my_config.width or new_config.height ~= my_config.height then
						config = new_config
						vim.api.nvim_win_set_config(state.loading_win, {
							width = new_config.width,
							height = new_config.height,
						})
					end

					local lines = get_spinner_text()
					if buf and vim.api.nvim_buf_is_valid(buf) then
						vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
						vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
						vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
					end
				else
					M._update_loading_overlay()
				end
			else
				M._update_loading_overlay()
			end
		end)
	)
end

--- @param state chat.ChatTabpageState
local function _hide_loading_overlay(state)
	if state.loading_timer then
		state.loading_timer:stop()
		state.loading_timer:close()
		state.loading_timer = nil
	end

	if state.loading_win then
		if vim.api.nvim_win_is_valid(state.loading_win) then
			vim.api.nvim_win_close(state.loading_win, true)
		end
		state.loading_win = nil
	end
end

function M._update_loading_overlay()
	if not M.chat_is_visible() then
		return
	end

	local state = get_layout_state()
	if not state or not state.layout then
		return
	end

	local should_show = false
	if M._active_tab_index == 1 then
		should_show = M._chat_loading
	elseif M._active_tab_index == 2 then
		local cwd = vim.fn.getcwd(-1, vim.api.nvim_get_current_tabpage())
		cwd = cwd:gsub("\\", "/")
		should_show = M._dir_loading[cwd]
	end

	if should_show then
		_show_loading_overlay(state)
	else
		_hide_loading_overlay(state)
	end
end

--- @param loading boolean
function M.set_chat_loading(loading)
	M._chat_loading = loading
	M._update_loading_overlay()
end

--- @param dir string
--- @param loading boolean
function M.set_dir_loading(dir, loading)
	dir = dir:gsub("\\", "/")
	if dir == M._opts.chat_scratch_dir then
		M.set_chat_loading(loading)
	else
		M._dir_loading[dir] = loading
		M._update_loading_overlay()
	end
end

function M.chat_show()
	local state = ensure_layout()
	-- ensure_layout mounts the layout, which effectively "unhides" it
	if state.layout and state.layout.wins.body and vim.api.nvim_win_is_valid(state.layout.wins.body) then
		vim.api.nvim_set_current_win(state.layout.wins.body)
		vim.cmd.startinsert()
		M._update_loading_overlay()
	end
end

function M.chat_hide()
	local state = get_layout_state()
	if state then
		if state.layout then
			state.layout:unmount()
			M.chat_defocus()
			_hide_loading_overlay(state)
		end
	end
end

function M.chat_is_visible()
	local state = get_layout_state()
	if not state or not state.layout then
		return false
	end
	return state.layout:valid()
end

function M.chat_is_focused()
	local state = get_layout_state()
	if not state or not state.layout then
		return false
	end

	local cursor_win = vim.api.nvim_get_current_win()
	return state.layout:contains_win(cursor_win)
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

		if state.layout and state.layout.wins.body then
			vim.api.nvim_set_current_win(state.layout.wins.body)
			vim.cmd.startinsert()
		end
	end
end

function M.chat_defocus()
	local state = get_layout_state()
	if not state then
		return
	end

	-- Only refocus if we are currently in the chat
	if not M.chat_is_focused() then
		return
	end

	if state.last_focused_win ~= nil and vim.api.nvim_win_is_valid(state.last_focused_win) then
		vim.api.nvim_set_current_win(state.last_focused_win)
	else
		-- Fallback: find any non-chat window
		local all_wins = vim.api.nvim_tabpage_list_wins(0)
		for _, win in ipairs(all_wins) do
			if state.layout and not state.layout:contains_win(win) then
				state.last_focused_win = win
				vim.api.nvim_set_current_win(win)
				return
			end
		end
	end
end

--- @param index number
function M.chat_switch_tab(index)
	assert(type(index) == "number")
	-- Ensure layout exists and is valid
	local state = ensure_layout()

	-- We have 2 "tabs" in the UI (buttons)
	local num_tabs = 2

	index = math.floor(index)
	index = ((index - 1) % num_tabs) + 1
	M._active_tab_index = index
	update_button_state()

	for tabpage, other_state in pairs(M._tabpage_state) do
		ensure_chat_term_buf(tabpage, other_state)
	end
	M._update_loading_overlay()
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
	if M._opts.chat_scratch_dir then
		M._opts.chat_scratch_dir = M._opts.chat_scratch_dir:gsub("\\", "/")
	end
end

return M
