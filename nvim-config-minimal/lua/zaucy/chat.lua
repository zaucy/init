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

	vim.keymap.set({ "n", "v" }, key, function()
		M.chat_toggle()
	end, { desc = "Show/focus AI chat" })
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

function M.chat_clear()
	if not M.chat_valid() then
		return
	end

	M.chat_send("/clear")
	M.chat_send("\r")
end

return M
