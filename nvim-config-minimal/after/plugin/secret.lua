local function create_floating_window(opts)
	opts = opts or {}

	-- Calculate centered window size
	local width = opts.width or math.floor(vim.o.columns * 0.4)
	local height = opts.height or math.floor(vim.o.lines * 0.4)
	local row = opts.row or math.floor((vim.o.lines - height) / 2)
	local col = opts.col or math.floor((vim.o.columns - width) / 2)

	-- Create backdrop window first
	local backdrop_opts = {
		relative = "editor",
		style = "minimal",
		width = vim.o.columns,
		height = vim.o.lines,
		row = 0,
		col = 0,
		zindex = 10,
	}

	local backdrop_buf = vim.api.nvim_create_buf(false, true)
	local backdrop_win = vim.api.nvim_open_win(backdrop_buf, false, backdrop_opts)

	-- Set backdrop window options
	vim.api.nvim_win_set_option(backdrop_win, "winblend", 80)
	vim.api.nvim_win_set_option(backdrop_win, "winhighlight", "Normal:Normal")

	-- Create main floating window
	local win_opts = {
		relative = "editor",
		style = "minimal",
		width = width,
		height = height,
		row = row,
		col = col,
		border = opts.border or "rounded",
		zindex = 11,
	}

	local buf = vim.api.nvim_create_buf(false, true)
	local win = vim.api.nvim_open_win(buf, true, win_opts)

	-- Set window options
	vim.api.nvim_win_set_option(win, "winhighlight", "Normal:Normal")

	-- Function to close both windows
	local function close_windows()
		vim.api.nvim_win_close(win, true)
		vim.api.nvim_win_close(backdrop_win, true)
	end

	-- Add keymapping to close windows
	vim.keymap.set('n', 'q', close_windows, { buffer = buf, noremap = true, silent = true })
	vim.keymap.set('n', '<Esc>', close_windows, { buffer = buf, noremap = true, silent = true })

	-- Return window and buffer IDs for further manipulation
	return {
		win = win,
		buf = buf,
		width = width,
		height = height,
		backdrop_win = backdrop_win,
		backdrop_buf = backdrop_buf,
		close = close_windows
	}
end

local function center_text_horizontal(text, width)
	local padding = math.floor((width - vim.fn.strdisplaywidth(text)) / 2)
	return string.rep(" ", padding) .. text
end

-- Utility function to center text both horizontally and vertically
local function set_centered_text(buf, width, height, lines)
	if type(lines) == "string" then
		lines = vim.split(lines, "\n")
	end

	-- Center text horizontally
	local centered_lines = {}
	for _, line in ipairs(lines) do
		table.insert(centered_lines, center_text_horizontal(line, width))
	end

	-- Center text vertically
	local top_padding = math.floor((height - #centered_lines) / 2)
	local padded_lines = {}

	-- Add top padding
	for _ = 1, top_padding do
		table.insert(padded_lines, string.rep(" ", width))
	end

	-- Add centered text
	for _, line in ipairs(centered_lines) do
		table.insert(padded_lines, line)
	end

	-- Add bottom padding
	while #padded_lines < height do
		table.insert(padded_lines, string.rep(" ", width))
	end

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, padded_lines)
end

local function secret_mode()
	local w = create_floating_window({
		border = "none",
	});
	set_centered_text(w.buf, w.width, w.height, {
		"Zeke is currently working on something in",
		"the background that can't be shown on stream",
		"",
		"Will be back soon!",
	})
end

vim.api.nvim_create_user_command(
	"SecretMode",
	secret_mode,
	{ desc = "Open 'secret' obscuring window" })
