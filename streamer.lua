local function is_started_in_streamer_mode()
	for _, arg in ipairs(vim.v.argv) do
		if arg == "+StreamerMode" then
			return true;
		end
	end

	return false
end

local function streamer_mode()
	vim.g.zaucy_streamer_mode = true

	if not is_started_in_streamer_mode() then
		vim.cmd("Reload")
	end

	vim.g.neovide_padding_top = 5
	vim.g.neovide_padding_left = 5
	vim.o.title = true
	vim.o.titlestring = "neovide (streamer mode)"

	require('proj').add_exclude_dir(vim.fn.expand('~/projects/priv'))
end

vim.api.nvim_create_user_command("StreamerMode", streamer_mode,
	{ desc = "Restarts neovide and re-open it in 'streamer' mode" })
