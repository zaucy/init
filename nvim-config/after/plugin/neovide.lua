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

vim.keymap.set('n', '<M-=>', function()
	vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.07
end)

vim.keymap.set('n', '<M-->', function()
	vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.07
end)

vim.keymap.set('n', '<M-0>', function()
	vim.g.neovide_scale_factor = 1.0
end)
