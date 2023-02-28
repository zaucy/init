if not vim.g.neovide then
	return
end

vim.keymap.set('n', '<F11>', function()
	if vim.g.neovide_fullscreen then
		vim.g.neovide_fullscreen = false
	else
		vim.g.neovide_fullscreen = true
	end
end)
