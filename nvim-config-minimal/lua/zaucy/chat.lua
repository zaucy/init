local M = {}

M._existing_window = nil
M._toggle_key = nil

function M.chat_valid()
	return M._existing_window and M._existing_window:buf_valid()
end

function M.chat_ensure()
	local snacks = require("snacks")
	if not M.chat_valid() then
		M._existing_window = snacks.win({
			width = 0.4,
			height = 0.99999,
			min_width = 90,
			position = "float",
			backdrop = 100,
			title = "󰚩 󰭹 chat",
			border = "left",
			col = 0.99999,
			fixbuf = true,
			wo = {
				signcolumn = "no",
				wrap = false,
			},
		})

		local chat_scratch_dir =
			vim.fn.substitute(vim.fn.expand("~/projects/zaucy/init/scratch/chat"), "\\\\", "/", "g")

		local orig_cwd = vim.fn.getcwd(0, 0)
		vim.cmd.lcd(chat_scratch_dir)
		vim.cmd.terminal("gemini")
		vim.cmd.startinsert()
		vim.cmd.lcd(orig_cwd)

		vim.keymap.set({ "t" }, M._toggle_key, function()
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
			M.chat_hide()
		end, { desc = "Hide AI chat", buffer = vim.api.nvim_get_current_buf() })

		return true
	end

	return false
end

function M.chat_toggle()
	if not M.chat_ensure() then
		if M._existing_window:valid() then
			M._existing_window:hide()
		else
			M._existing_window:show()
			M._existing_window:focus()
			vim.cmd.startinsert()
		end
	end
end

function M.chat_hide()
	local w = M._existing_window
	if not w then
		return
	end

	w:hide()
end

function M.chat_show()
	local w = M._existing_window
	if not w then
		return
	end

	w:show()
	w:focus()
	vim.cmd.startinsert()
end

function M.set_toggle_key(key)
	assert(M._toggle_key == nil, "chat toggle key already set")
	M._toggle_key = key

	vim.keymap.set({ "n" }, key, function()
		M.chat_toggle()
	end, { desc = "Show/focus AI chat" })

	vim.keymap.set({ "v" }, key, function()
		-- ESCAPE visual mode to update the '< and '> marks
		vim.cmd("noau normal! \27")

		local s = vim.api.nvim_buf_get_mark(0, "<")
		local e = vim.api.nvim_buf_get_mark(0, ">")

		-- basic validation to ensure marks are set
		if s[1] == 0 or e[1] == 0 then
			return
		end

		local lines = vim.api.nvim_buf_get_text(0, s[1] - 1, s[2], e[1] - 1, e[2] + 1, {})
		local ft = vim.bo.filetype

		local min_indent = math.huge
		for i, line in ipairs(lines) do
			line = line:gsub("\t", string.rep(" ", vim.bo.tabstop))
			lines[i] = line
			if line:match("%S") then
				local indent = #line:match("^%s*")
				if indent < min_indent then
					min_indent = indent
				end
			end
		end
		if min_indent == math.huge then
			min_indent = 0
		end

		for i, line in ipairs(lines) do
			lines[i] = line:sub(min_indent + 1)
		end

		local text = table.concat(lines, "\n")
		text = "```" .. ft .. "\n" .. text .. "\n```\n"

		vim.schedule(function()
			M.chat_send(text)
		end)
	end, { desc = "Send selected to chat", silent = true })
end

function M.chat_send(text)
	M.chat_ensure()
	M.chat_show()
	local bufnr = vim.api.nvim_get_current_buf()
	local chan = vim.b[bufnr].terminal_job_id

	if chan > 0 then
		vim.api.nvim_chan_send(chan, text)
	end
end

--- Send multiple strings to a terminal channel with a delay in between
--- @param chan number channel number
--- @param delay_ms number delay in milliseconds between sends
--- @param messages table<string>
local function chan_send_with_delay(chan, delay_ms, messages)
	local i = 1
	local function send_next()
		if i <= #messages then
			vim.api.nvim_chan_send(chan, messages[i])
			i = i + 1
			vim.defer_fn(send_next, delay_ms)
		end
	end

	send_next()
end

function M.chat_command(name)
	local w = M._existing_window
	if not w or not w:buf_valid() then
		return
	end

	local bufnr = w.buf
	local chan = vim.b[bufnr].terminal_job_id

	if chan > 0 then
		chan_send_with_delay(chan, 60, { "\27", "\27", "/" .. name, "\r" })
	end
end

function M.chat_clear()
	M.chat_command("clear")
end

return M
