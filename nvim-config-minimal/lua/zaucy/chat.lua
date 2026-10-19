--- @class chat.TabConfig
--- @field type? "terminal"|"buffer"
--- @field cmd? string|fun(dir: string): string|number|chat.TabConfig|nil
--- @field mode? "normal"|"insert"

--- @class chat.SetupOptions
--- @field chat_scratch_dir? string
--- @field terminal_command? string|fun(dir: string): string|chat.TabConfig
--- @field chat? chat.TabConfig|fun(dir: string): chat.TabConfig|string
--- @field cwd? chat.TabConfig|fun(dir: string): chat.TabConfig|string

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

	--- @type boolean
	_is_fullscreen = false,
}

local ns = vim.api.nvim_create_namespace("ZaucyChatTabs")
vim.api.nvim_set_hl(ns, "Cursor", { blend = 100 })

-- Create a "ghost" highlight that is nearly invisible
local function setup_ghost_hl()
	local ghost_props = { fg = "bg", bg = "bg", blend = 100 }
	local groups = {
		"Normal",
		"NormalFloat",
		"FloatBorder",
		"EndOfBuffer",
		"TermCursor",
		"Visual",
		"Search",
		"IncSearch",
		"Identifier",
		"Statement",
		"PreProc",
		"Type",
		"Special",
		"Underlined",
		"Ignore",
		"Error",
		"Todo",
		"String",
		"Character",
		"Number",
		"Boolean",
		"Float",
		"Function",
		"Conditional",
		"Repeat",
		"Label",
		"Operator",
		"Keyword",
		"Exception",
		"Include",
		"Define",
		"Macro",
		"PreCondit",
		"StorageClass",
		"Structure",
		"Typedef",
		"Tag",
		"Delimiter",
		"SpecialChar",
		"Debug",
		"Directory",
		"ModeMsg",
		"MoreMsg",
		"Question",
		"StatusLine",
		"StatusLineNC",
		"VertSplit",
		"Title",
		"NonText",
		"Comment",
		"Constant",
		"SpecialKey",
		"WarningMsg",
		"ErrorMsg",
	}
	for _, group in ipairs(groups) do
		vim.api.nvim_set_hl(ns, group, ghost_props)
	end
end
setup_ghost_hl()

local global_augroup = vim.api.nvim_create_augroup("ZaucyChatGlobal", { clear = true })

function M._ensure_global_autocmds()
	vim.api.nvim_clear_autocmds({ group = global_augroup })
	vim.api.nvim_create_autocmd("VimResized", {
		group = global_augroup,
		callback = function()
			for _, state in pairs(M._tabpage_state) do
				if state.layout and state.layout:valid() then
					state.layout:resize()
				end
			end
			M._update_transparency()
		end,
	})
	vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI", "WinEnter" }, {
		group = global_augroup,
		callback = function()
			M._update_transparency()
		end,
	})
end

function M._cleanup_global_autocmds()
	local any_valid = false
	for _, state in pairs(M._tabpage_state) do
		if state.layout and state.layout:valid() then
			any_valid = true
			break
		end
	end
	if not any_valid then
		vim.api.nvim_clear_autocmds({ group = global_augroup })
	end
end

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
	if vim.bo[buf].buftype == "terminal" then
		vim.keymap.set({ "t" }, "<S-CR>", "\\\r", { buffer = buf })
		vim.keymap.set({ "t" }, "<C-CR>", "\\\r", { buffer = buf })
	end
	vim.keymap.set({ "t", "v", "n" }, "<C-S-Left>", function()
		M.chat_switch_tab(1)
	end, { buffer = buf })
	vim.keymap.set({ "t", "v", "n" }, "<C-S-Right>", function()
		M.chat_switch_tab(2)
	end, { buffer = buf })
end

local function get_terminal_command(dir)
	if type(M._opts.terminal_command) == "function" then
		return M._opts.terminal_command(dir)
	end
	return M._opts.terminal_command
end

--- @param tab_index number
--- @param dir string
--- @return chat.TabConfig
local function get_tab_config(tab_index, dir)
	local raw = (tab_index == 1) and M._opts.chat or M._opts.cwd

	if type(raw) == "function" then
		raw = raw(dir)
	end

	if type(raw) == "string" then
		if raw:match("^:?e%s+") or raw:match("^:?edit%s+") or raw:match("://") then
			return { type = "buffer", cmd = raw, mode = "normal" }
		else
			return { type = "terminal", cmd = raw, mode = "insert" }
		end
	end

	if type(raw) == "table" then
		local tab_type = raw.type
		if type(tab_type) == "function" then
			tab_type = tab_type(dir)
		end

		local cmd = raw.cmd
		local mode = raw.mode
		if type(cmd) == "function" then
			local res = cmd(dir)
			if type(res) == "table" then
				return {
					type = res.type or tab_type or "terminal",
					cmd = res.cmd,
					mode = res.mode or mode,
				}
			elseif type(res) == "string" or type(res) == "number" then
				cmd = res
			end
		end

		if tab_type == nil then
			if type(cmd) == "string" and (cmd:match("^:?e%s+") or cmd:match("^:?edit%s+") or cmd:match("://")) then
				tab_type = "buffer"
			else
				tab_type = "terminal"
			end
		end

		return {
			type = tab_type,
			cmd = cmd or get_terminal_command(dir),
			mode = mode,
		}
	end

	local fallback = get_terminal_command(dir)
	if type(fallback) == "table" then
		return {
			type = fallback.type or "terminal",
			cmd = fallback.cmd,
			mode = fallback.mode or "insert",
		}
	elseif type(fallback) == "string" and (fallback:match("^:?e%s+") or fallback:match("^:?edit%s+") or fallback:match("://")) then
		return {
			type = "buffer",
			cmd = fallback,
			mode = "normal",
		}
	end

	return {
		type = "terminal",
		cmd = fallback,
		mode = "insert",
	}
end

--- @param tab_index number
--- @param dir string
--- @param tab_config chat.TabConfig
--- @return number
local function open_tab_buf(tab_index, dir, tab_config)
	local cmd = tab_config.cmd
	if type(cmd) == "function" then
		local res = cmd(dir)
		if type(res) == "table" then
			tab_config = res
			cmd = tab_config.cmd
		elseif type(res) == "number" and vim.api.nvim_buf_is_valid(res) then
			bind_chat_keys(res)
			vim.api.nvim_exec_autocmds("User", {
				pattern = "ZaucyChatBufCreated",
				data = { bufnr = res, tab_index = tab_index },
			})
			return res
		elseif type(res) == "string" then
			cmd = res
		end
	end

	local orig_cwd = vim.fn.getcwd(0, 0)
	local changed_dir = false
	if dir and dir ~= "" then
		changed_dir = pcall(vim.cmd.lcd, dir)
	end

	local new_buf
	if tab_config.type == "buffer" then
		if type(cmd) == "string" and cmd ~= "" then
			if cmd:match("^:?e%s+") or cmd:match("^:?edit%s+") or cmd:sub(1, 1) == ":" then
				local clean_cmd = cmd:gsub("^:", "")
				vim.cmd(clean_cmd)
			else
				vim.cmd.edit(cmd)
			end
		end
		new_buf = vim.api.nvim_get_current_buf()
		bind_chat_keys(new_buf)
		vim.api.nvim_exec_autocmds("User", {
			pattern = "ZaucyChatBufCreated",
			data = { bufnr = new_buf, tab_index = tab_index },
		})
	else
		local term_cmd = cmd
		if type(term_cmd) ~= "string" or term_cmd == "" then
			term_cmd = get_terminal_command(dir)
		end
		vim.cmd.terminal(term_cmd)
		new_buf = vim.api.nvim_get_current_buf()
		bind_chat_keys(new_buf)
		vim.api.nvim_exec_autocmds("User", {
			pattern = "ZaucyChatTerminalBufCreated",
			data = { terminal_bufnr = new_buf, tab_index = tab_index },
		})
		vim.api.nvim_exec_autocmds("User", {
			pattern = "ZaucyChatBufCreated",
			data = { bufnr = new_buf, tab_index = tab_index },
		})
	end

	if changed_dir then
		pcall(vim.cmd.lcd, orig_cwd)
	end
	return new_buf
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
		local orig_cwd = vim.fn.getcwd(0, 0)
		local dir = M._opts.chat_scratch_dir or orig_cwd
		local conf = get_tab_config(1, dir)

		vim.api.nvim_win_call(body_win, function()
			vim.wo[body_win].winfixbuf = false
			if M._chat_term_buf and vim.api.nvim_buf_is_valid(M._chat_term_buf) then
				vim.api.nvim_win_set_buf(body_win, M._chat_term_buf)
			else
				local buf = open_tab_buf(1, dir, conf)
				M._chat_term_buf = buf
				vim.api.nvim_win_set_buf(body_win, buf)
			end
			vim.wo[body_win].winfixbuf = true
		end)
		return
	end

	local cwd = vim.fn.getcwd(-1, tabpage)
	cwd = cwd:gsub("\\", "/")
	local conf = get_tab_config(2, cwd)

	vim.api.nvim_win_call(body_win, function()
		local buf = M._dir_term_bufs[cwd]
		vim.wo[body_win].winfixbuf = false
		if buf == nil or not vim.api.nvim_buf_is_valid(buf) then
			buf = open_tab_buf(2, cwd, conf)
			M._dir_term_bufs[cwd] = buf
			vim.api.nvim_win_set_buf(body_win, buf)
		else
			vim.api.nvim_win_set_buf(body_win, buf)
		end
		vim.wo[body_win].winfixbuf = true
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
	return self
end

function Layout:get_geometry()
	local editor_width = vim.o.columns
	local editor_height = vim.o.lines

	if M._is_fullscreen then
		return {
			col = 0,
			row = 0,
			width = editor_width,
			height = editor_height,
		}
	end

	local width = math.floor(editor_width * 0.4)
	if width < 90 then
		width = 90
	end
	local offset_x = 4
	local offset_y_top = 2
	local offset_y_bottom = math.max(5, (vim.o.cmdheight or 1) + (vim.o.laststatus > 0 and 1 or 0) + 3)
	local max_width = math.max(1, editor_width - offset_x - 2)
	if width > max_width then
		width = max_width
	end

	local col = math.max(1, editor_width - width - offset_x)
	local row = offset_y_top
	local height = math.max(1, editor_height - offset_y_top - offset_y_bottom)

	return {
		col = col,
		row = row,
		width = width,
		height = height,
	}
end

function Layout:update_text()
	local geo = self:get_geometry()
	local btn1_width = 13
	local cwd_btn_width = math.max(1, geo.width - btn1_width)

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
		if #line_text > cwd_btn_width then
			line_text = cwd:sub(-cwd_btn_width)
		end
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

	-- Chat Button Window (top-left rounded corner, top border, left border)
	self.wins.chat_btn = vim.api.nvim_open_win(self.bufs.chat_btn, false, {
		relative = "editor",
		row = geo.row,
		col = geo.col,
		width = btn1_width,
		height = header_height,
		style = "minimal",
		border = M._is_fullscreen and "none" or { "╭", "─", "", "", "", "", "", "│" },
		focusable = true,
		zindex = 50,
	})
	setup_window_props(self.wins.chat_btn)
	vim.wo[self.wins.chat_btn].wrap = false
	vim.wo[self.wins.chat_btn].winfixbuf = true

	local border_w = M._is_fullscreen and 0 or 1

	-- CWD Button Window (top border, top-right rounded corner, right border)
	self.wins.cwd_btn = vim.api.nvim_open_win(self.bufs.cwd_btn, false, {
		relative = "editor",
		row = geo.row,
		col = geo.col + btn1_width + border_w,
		width = math.max(1, geo.width - btn1_width),
		height = header_height,
		style = "minimal",
		border = M._is_fullscreen and "none" or { "", "─", "╮", "│", "", "", "", "" },
		focusable = true,
		zindex = 50,
	})
	setup_window_props(self.wins.cwd_btn)
	vim.wo[self.wins.cwd_btn].wrap = false
	vim.wo[self.wins.cwd_btn].winfixbuf = true

	vim.keymap.set({ "n", "v" }, "<LeftMouse>", function()
		M.chat_switch_tab(1)
		if self.wins.body and vim.api.nvim_win_is_valid(self.wins.body) then
			vim.api.nvim_set_current_win(self.wins.body)
		end
	end, { buffer = self.bufs.chat_btn, silent = true })

	vim.keymap.set({ "n", "v" }, "<LeftMouse>", function()
		M.chat_switch_tab(2)
		if self.wins.body and vim.api.nvim_win_is_valid(self.wins.body) then
			vim.api.nvim_set_current_win(self.wins.body)
		end
	end, { buffer = self.bufs.cwd_btn, silent = true })

	-- Body Window (divider line with T-junctions at top, left and right borders, bottom rounded corners)
	-- Use a temp buffer initially
	local body_buf = vim.api.nvim_create_buf(false, true)
	self.wins.body = vim.api.nvim_open_win(body_buf, true, {
		relative = "editor",
		row = geo.row + header_height + 1,
		col = geo.col,
		width = geo.width,
		height = math.max(1, geo.height - header_height - 1),
		style = "minimal",
		border = M._is_fullscreen and "none" or { "├", "─", "┤", "│", "╯", "─", "╰", "│" },
		focusable = true,
		zindex = 50,
	})
	vim.api.nvim_set_option_value("winhighlight", "NormalFloat:Normal", { win = self.wins.body })
	vim.wo[self.wins.body].wrap = false
	vim.wo[self.wins.body].winfixbuf = true

	self.augroup = vim.api.nvim_create_augroup("ZaucyChatLayout_" .. self.wins.body, { clear = true })

	vim.api.nvim_create_autocmd("WinEnter", {
		group = self.augroup,
		callback = function()
			local cur_win = vim.api.nvim_get_current_win()
			if cur_win == self.wins.chat_btn then
				M.chat_switch_tab(1)
				if self.wins.body and vim.api.nvim_win_is_valid(self.wins.body) then
					vim.schedule(function()
						if self.wins.body and vim.api.nvim_win_is_valid(self.wins.body) then
							vim.api.nvim_set_current_win(self.wins.body)
						end
					end)
				end
			elseif cur_win == self.wins.cwd_btn then
				M.chat_switch_tab(2)
				if self.wins.body and vim.api.nvim_win_is_valid(self.wins.body) then
					vim.schedule(function()
						if self.wins.body and vim.api.nvim_win_is_valid(self.wins.body) then
							vim.api.nvim_set_current_win(self.wins.body)
						end
					end)
				end
			end
		end,
	})

	vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
		group = self.augroup,
		callback = function(args)
			local cur_win = vim.api.nvim_get_current_win()
			if cur_win == self.wins.body then
				local buf = args.buf or vim.api.nvim_win_get_buf(cur_win)
				if buf and vim.api.nvim_buf_is_valid(buf) then
					bind_chat_keys(buf)
					vim.api.nvim_exec_autocmds("User", {
						pattern = "ZaucyChatBufCreated",
						data = { bufnr = buf, tab_index = M._active_tab_index },
					})
					if M._active_tab_index == 1 then
						M._chat_term_buf = buf
					elseif M._active_tab_index == 2 then
						local tabpage = vim.api.nvim_get_current_tabpage()
						local cwd = vim.fn.getcwd(-1, tabpage):gsub("\\", "/")
						M._dir_term_bufs[cwd] = buf
					end
				end
			end
		end,
	})

	-- Cleanup Autocmd (if any window is closed via :q etc)
	vim.api.nvim_create_autocmd("WinClosed", {
		group = self.augroup,
		pattern = {
			tostring(self.wins.body),
			tostring(self.wins.chat_btn),
			tostring(self.wins.cwd_btn),
		},
		callback = function()
			vim.schedule(function()
				self:unmount()
			end)
		end,
	})

	vim.api.nvim_create_autocmd("WinLeave", {
		group = self.augroup,
		callback = function()
			if M._is_fullscreen then
				local left_win = vim.api.nvim_get_current_win()
				if self:contains_win(left_win) then
					vim.schedule(function()
						if not M.chat_is_focused() then
							M.chat_hide()
						end
					end)
				end
			end
		end,
	})

	M._ensure_global_autocmds()
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
			border = M._is_fullscreen and "none" or { "╭", "─", "", "", "", "", "", "│" },
		})
	end

	local border_w = M._is_fullscreen and 0 or 1

	if self.wins.cwd_btn and vim.api.nvim_win_is_valid(self.wins.cwd_btn) then
		vim.api.nvim_win_set_config(self.wins.cwd_btn, {
			relative = "editor",
			row = geo.row,
			col = geo.col + btn1_width + border_w,
			width = math.max(1, geo.width - btn1_width),
			height = header_height,
			border = M._is_fullscreen and "none" or { "", "─", "╮", "│", "", "", "", "" },
		})
	end

	if self.wins.body and vim.api.nvim_win_is_valid(self.wins.body) then
		vim.api.nvim_win_set_config(self.wins.body, {
			relative = "editor",
			row = geo.row + header_height + 1,
			col = geo.col,
			width = geo.width,
			height = math.max(1, geo.height - header_height - 1),
			border = M._is_fullscreen and "none" or { "├", "─", "┤", "│", "╯", "─", "╰", "│" },
		})
	end

	self:update_text()
	update_button_state()
end

function M._reset_transparency()
	local all_wins = vim.api.nvim_tabpage_list_wins(0)
	for _, win in ipairs(all_wins) do
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_set_option_value("winblend", 0, { win = win })
			vim.api.nvim_win_set_hl_ns(win, 0)
			vim.api.nvim_set_option_value("winhighlight", "", { win = win })
		end
	end
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
	if self.augroup then
		vim.api.nvim_clear_autocmds({ group = self.augroup })
		self.augroup = nil
	end
	self.wins = { body = nil, chat_btn = nil, cwd_btn = nil }
	M._reset_transparency()
	M._cleanup_global_autocmds()
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

	M._update_transparency()
end

function M._update_transparency()
	local state = get_layout_state()
	if not state or not state.layout then
		return
	end

	local is_underneath = false
	if not M.chat_is_focused() then
		local cursor_pos = vim.fn.screenpos(0, vim.fn.line("."), vim.fn.col("."))
		local r = cursor_pos.row
		local c = cursor_pos.col

		if r > 0 and c > 0 then
			local check_wins = state.layout:get_wins()
			if state.loading_win and vim.api.nvim_win_is_valid(state.loading_win) then
				table.insert(check_wins, state.loading_win)
			end

			for _, win in ipairs(check_wins) do
				if vim.api.nvim_win_is_valid(win) then
					local pos = vim.fn.win_screenpos(win)
					local win_r = pos[1]
					local win_c = pos[2]
					local win_w = vim.api.nvim_win_get_width(win)
					local win_h = vim.api.nvim_win_get_height(win)

					local config = vim.api.nvim_win_get_config(win)
					if config.border then
						if type(config.border) == "string" and config.border ~= "none" then
							win_r = win_r - 1
							win_c = win_c - 1
							win_w = win_w + 2
							win_h = win_h + 2
						elseif type(config.border) == "table" then
							local b = config.border
							if #b >= 8 then
								if b[1] ~= "" or b[2] ~= "" or b[3] ~= "" then
									win_h = win_h + 1
									win_r = win_r - 1
								end -- top
								if b[5] ~= "" or b[6] ~= "" or b[7] ~= "" then
									win_h = win_h + 1
								end -- bottom
								if b[7] ~= "" or b[8] ~= "" or b[1] ~= "" then
									win_w = win_w + 1
									win_c = win_c - 1
								end -- left
								if b[3] ~= "" or b[4] ~= "" or b[5] ~= "" then
									win_w = win_w + 1
								end -- right
							end
						end
					end

					if r >= win_r and r < win_r + win_h and c >= win_c and c < win_c + win_w then
						is_underneath = true
						break
					end
				end
			end
		end
	end

	local blend = is_underneath and 90 or 0
	local wins = state.layout:get_wins()
	if state.loading_win and vim.api.nvim_win_is_valid(state.loading_win) then
		table.insert(wins, state.loading_win)
	end

	for _, win in ipairs(wins) do
		if vim.api.nvim_win_is_valid(win) then
			if state.loading_win == win and not is_underneath then
				vim.api.nvim_set_option_value("winblend", 80, { win = win })
				vim.api.nvim_win_set_hl_ns(win, 0)
				vim.api.nvim_set_option_value("winhighlight", "", { win = win })
			else
				vim.api.nvim_set_option_value("winblend", blend, { win = win })
				if is_underneath then
					vim.api.nvim_win_set_hl_ns(win, ns)
					vim.api.nvim_set_option_value(
						"winhighlight",
						"Normal:Normal,FloatBorder:FloatBorder,NormalFloat:NormalFloat",
						{ win = win }
					)
				else
					vim.api.nvim_win_set_hl_ns(win, 0)
					if win == state.layout.wins.body then
						vim.api.nvim_set_option_value("winhighlight", "NormalFloat:Normal", { win = win })
					else
						vim.api.nvim_set_option_value("winhighlight", "", { win = win })
					end
				end
			end
		end
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

function M._apply_tab_mode(win, tab_index)
	if not win or not vim.api.nvim_win_is_valid(win) then
		return
	end
	local tabpage = vim.api.nvim_get_current_tabpage()
	local orig_cwd = vim.fn.getcwd(0, 0)
	local dir = (tab_index == 1) and (M._opts.chat_scratch_dir or orig_cwd) or vim.fn.getcwd(-1, tabpage):gsub("\\", "/")
	local conf = get_tab_config(tab_index, dir)
	local buf = vim.api.nvim_win_get_buf(win)
	local is_term = vim.bo[buf].buftype == "terminal"

	local mode = conf.mode
	if mode == nil then
		mode = is_term and "insert" or "normal"
	end

	if mode == "insert" then
		vim.cmd.startinsert()
	else
		vim.cmd.stopinsert()
	end
end

function M.chat_show()
	local state = ensure_layout()
	-- ensure_layout mounts the layout, which effectively "unhides" it
	if state.layout and state.layout.wins.body and vim.api.nvim_win_is_valid(state.layout.wins.body) then
		vim.api.nvim_set_current_win(state.layout.wins.body)
		M._apply_tab_mode(state.layout.wins.body, M._active_tab_index)
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
			M._apply_tab_mode(state.layout.wins.body, M._active_tab_index)
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

	-- Save the active buffer of the current tab before switching
	if state.layout and state.layout.wins.body and vim.api.nvim_win_is_valid(state.layout.wins.body) then
		local cur_buf = vim.api.nvim_win_get_buf(state.layout.wins.body)
		if cur_buf and vim.api.nvim_buf_is_valid(cur_buf) then
			if M._active_tab_index == 1 then
				M._chat_term_buf = cur_buf
			elseif M._active_tab_index == 2 then
				local tabpage = vim.api.nvim_get_current_tabpage()
				local cur_cwd = vim.fn.getcwd(-1, tabpage):gsub("\\", "/")
				M._dir_term_bufs[cur_cwd] = cur_buf
			end
		end
	end

	-- We have 2 "tabs" in the UI (buttons)
	local num_tabs = 2

	index = math.floor(index)
	index = ((index - 1) % num_tabs) + 1
	M._active_tab_index = index
	update_button_state()

	for tabpage, other_state in pairs(M._tabpage_state) do
		ensure_chat_term_buf(tabpage, other_state)
	end

	if state.layout and state.layout.wins.body and vim.api.nvim_win_is_valid(state.layout.wins.body) then
		if M.chat_is_focused() then
			M._apply_tab_mode(state.layout.wins.body, M._active_tab_index)
		end
	end

	M._update_loading_overlay()
end

function M.chat_switch_tab_next()
	M.chat_switch_tab(M._active_tab_index + 1)
end

function M.chat_switch_tab_prev()
	M.chat_switch_tab(M._active_tab_index - 1)
end

--- @param is_fullscreen boolean
function M.chat_set_fullscreen(is_fullscreen)
	M._is_fullscreen = is_fullscreen
	for _, state in pairs(M._tabpage_state) do
		if state.layout and state.layout:valid() then
			state.layout:resize()
		end
	end
	M._update_loading_overlay()
end

--- @param opts chat.SetupOptions
function M.setup(opts)
	M._opts = vim.tbl_deep_extend("force", M._opts, opts)
	if M._opts.chat_scratch_dir then
		M._opts.chat_scratch_dir = M._opts.chat_scratch_dir:gsub("\\", "/")
	end
end

return M
