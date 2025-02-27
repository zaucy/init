local function get_current_buffer_path()
	local bufname = vim.api.nvim_buf_get_name(0)
	return vim.fn.fnamemodify(bufname, ":p")
end

local function screenshot()
	-- local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
	-- local bg_color = normal_hl.bg
	-- local bg_hex = string.format("#%06x", bg_color) or "#282a36"
	local bg_hex = "#282a36"
	local buffer_path = get_current_buffer_path()
	local args = {
		buffer_path,
		"--no-line-number",
		"--no-round-corner",
		"--no-window-controls",
		"--background=" .. bg_hex,
		"--to-clipboard",
	}

	vim.uv.spawn("silicon", {
		args = args,
	}, function(code)
		if code == 0 then
			vim.notify("Screenshot added to clipboard")
		else
			vim.notify("Failed to make screenshot of buffer", vim.log.levels.ERROR)
		end
	end)
end

vim.api.nvim_create_user_command("Screenshot", screenshot, { desc = "Take a screenshot of current buffer" })
