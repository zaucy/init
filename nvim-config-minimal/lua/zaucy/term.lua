local term_buf_closed = {}

--- tabpage -> term_args -> buf
--- @type table<integer, table<string, integer>>
local term_buf_by_type = {}

--- term_args -> window -> buf
--- @type table<integer, table<string, table<string, integer>>>
local last_buf_before_terminal_by_type = {}

local function is_bufvalid(buf)
	if buf == nil then
		return false
	end
	if not vim.api.nvim_buf_is_valid(buf) then
		return false
	end
	local buftype = vim.bo[buf].buftype

	if buftype == "terminal" then
		if vim.bo[buf].buflisted == 0 then
			return false
		end
		return not term_buf_closed[buf]
	end

	if buftype == "prompt" then
		return false
	end
	if buftype == "nofile" then
		return false
	end
	return true
end

vim.api.nvim_create_autocmd("TermClose", {
	callback = function(event)
		term_buf_closed[event.buf] = true
	end,
})

-- vim.api.nvim_create_autocmd({ "BufWinEnter", "BufEnter" }, {
-- 	callback = function()
-- 		if vim.bo.buftype == "terminal" then
-- 			last_term_buf[vim.api.nvim_get_current_tabpage()] = vim.api.nvim_get_current_buf()
-- 		end
-- 	end,
-- })

-- vim.api.nvim_create_autocmd({ "TermOpen" }, {
-- 	callback = function()
-- 		if vim.bo.buftype == "terminal" then
-- 			local tabpage = vim.api.nvim_get_current_tabpage()
-- 			local buf = vim.api.nvim_get_current_buf()
-- 			last_term_buf[tabpage] = buf
-- 			if not tabpage_terms[tabpage] then
-- 				tabpage_terms[tabpage] = {}
-- 			end
-- 			table.insert(tabpage_terms[tabpage], buf)
-- 		end
-- 	end,
-- })

local function find_nearby_valid_buf(bufs, start_index)
	local offset = 1
	while true do
		if start_index + offset > #bufs and start_index - offset < 0 then
			return nil
		end

		if is_bufvalid(bufs[start_index + offset]) then
			return bufs[start_index + offset]
		elseif is_bufvalid(bufs[start_index - offset]) then
			return bufs[start_index - offset]
		end

		offset = offset + 1
	end
end

--- @param term_args string
--- @return fun()
local function close_terminal(term_args)
	return function()
		if vim.bo.buftype ~= "terminal" then
			return
		end

		local win = vim.api.nvim_get_current_win()
		local currbuf = vim.fn.winbufnr(win)

		last_buf_before_terminal_by_type[term_args] = last_buf_before_terminal_by_type[term_args] or {}

		if is_bufvalid(last_buf_before_terminal_by_type[term_args][win]) then
			vim.api.nvim_set_current_buf(last_buf_before_terminal_by_type[term_args][win])
			return
		end

		last_buf_before_terminal_by_type[term_args][win] = nil

		local allbufs = vim.api.nvim_list_bufs()
		for i, buf in ipairs(allbufs) do
			if buf == currbuf then
				local nearby_buf = find_nearby_valid_buf(allbufs, i)
				if nearby_buf ~= nil then
					vim.api.nvim_set_current_buf(nearby_buf)
				else
					vim.cmd("enew")
				end
				return
			end
		end

		vim.cmd("enew")
	end
end

--- @class SetupTerminalToggleOptions
--- @field keymaps string[]
--- @field term_args string fields passed to :terminal command
--- @field start_in_terminal_mode ?boolean
--- @field on_before_open ?fun()
--- @field on_after_open ?fun()
--- @field forwarded_keys ?string[] keys that should be automatically executed in normal mode even when in terminal mode

--- @param opts SetupTerminalToggleOptions
local function setup_terminal_toggle(opts)
	local keymaps = opts.keymaps
	local term_args = opts.term_args
	local start_in_terminal_mode = opts.start_in_terminal_mode or false
	local forwarded_keys = opts.forwarded_keys or {}
	local open_terminal_fn = function()
		local close_fn = close_terminal(term_args)

		local tabpage = vim.api.nvim_get_current_tabpage()
		term_buf_by_type[tabpage] = term_buf_by_type[tabpage] or {}

		if vim.bo.buftype == "terminal" then
			local curr_terminal_buf = vim.api.nvim_get_current_buf()
			if term_buf_by_type[tabpage][term_args] == curr_terminal_buf then
				close_fn()
				return
			end
		end

		last_buf_before_terminal_by_type[term_args] = last_buf_before_terminal_by_type[term_args] or {}
		last_buf_before_terminal_by_type[term_args][vim.api.nvim_get_current_win()] = vim.api.nvim_get_current_buf()

		if is_bufvalid(term_buf_by_type[tabpage][term_args]) then
			---@diagnostic disable-next-line: param-type-mismatch
			vim.api.nvim_set_current_buf(term_buf_by_type[tabpage][term_args])
			if start_in_terminal_mode then
				vim.cmd("startinsert")
			end
			return
		end

		if opts.on_before_open then
			local success, error = pcall(opts.on_before_open)
			if not success then
				vim.notify(error, vim.log.levels.ERROR)
			end
		end

		vim.cmd("terminal " .. term_args)
		if start_in_terminal_mode then
			vim.cmd("startinsert")
		end

		if opts.on_after_open then
			local success, error = pcall(opts.on_after_open)
			if not success then
				vim.notify(error, vim.log.levels.ERROR)
			end
		end

		local terminal_bufnr = vim.api.nvim_get_current_buf()
		term_buf_by_type[tabpage][term_args] = terminal_bufnr

		for _, keymap in ipairs(keymaps) do
			vim.keymap.set({ "t" }, keymap, close_fn, { desc = "Hide Terminal", buffer = terminal_bufnr })
		end

		for _, key in ipairs(forwarded_keys) do
			vim.keymap.set({ "t" }, key, "<C-\\><C-n>" .. key, { buffer = terminal_bufnr, remap = true })
		end
	end

	for _, keymap in ipairs(keymaps) do
		vim.keymap.set({ "n" }, keymap, open_terminal_fn, { desc = "Open Terminal" })
	end
end

local function sigint_terminal()
	if vim.bo.buftype ~= "terminal" then
		return
	end

	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-c>", true, false, true), "n", true)
	vim.api.nvim_command("startinsert")
end

--- Toggle my main (nushell) terminal
setup_terminal_toggle({ keymaps = { "<C-_>", "<C-/>" }, term_args = "nu" })

--- Other misc shells I like to toggle on/off
setup_terminal_toggle({
	keymaps = { "<C-g>" },
	term_args = "gemini",
	start_in_terminal_mode = true,
	forwarded_keys = { "<C-o>", "<C-d>", "<C-u>", "<C-_>", "<C-/>", "<C-S-CR>" },
})

--- General terminal keys
vim.keymap.set({ "t" }, "<C-w>", "<C-\\><C-n><cmd>WhichKey <C-w><cr>", {})
vim.keymap.set({ "n", "v" }, "<C-c>", sigint_terminal, { desc = "Ctrl-C terminal", noremap = true, silent = true })
vim.keymap.set({ "t" }, "<S-Insert>", '<C-\\><C-n>"+pi', { desc = "Paste In Terminal" })
