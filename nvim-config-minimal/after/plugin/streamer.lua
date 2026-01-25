local function streamer_mode()
	vim.g.ZaucyStreamerMode = 1

	vim.g.neovide_padding_top = 5
	vim.g.neovide_padding_left = 0
	vim.g.neovide_frame = "none"
	vim.g.neovide_window_pos_x = 0
	vim.g.neovide_window_pos_y = 0
	vim.g.neovide_window_width = 2000
	vim.g.neovide_window_height = 1370
	vim.o.title = true
	if vim.g.wslenv then
		vim.o.titlestring = "neovide (streamer mode) (wsl)"
	else
		vim.o.titlestring = "neovide (streamer mode)"
	end

	require("proj").add_exclude_dir(vim.fn.expand("~/projects/priv"))
	require("proj").add_exclude_dir(vim.fn.expand("C:/d2d"))
	require("proj").add_exclude_dir(vim.fn.expand("E:/d2d"))
end

vim.api.nvim_create_user_command(
	"StreamerMode",
	streamer_mode,
	{ desc = "Restarts neovide and re-open it in 'streamer' mode" }
)

vim.api.nvim_create_autocmd("SessionLoadPost", {
	callback = function()
		if vim.g.ZaucyStreamerMode == 1 then
			streamer_mode()
		end
	end,
})
