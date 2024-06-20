vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.g.terminal_emulator = "nu"
vim.go.shell = "nu"

vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true

vim.filetype.add({
	extension = {
		nu = "nu",
	},
})

if vim.g.neovide then
	vim.g.neovide_scroll_animation_length = 0.08
	vim.g.neovide_hide_mouse_when_typing = true
	vim.g.neovide_cursor_animation_length = 0.04
	vim.g.neovide_cursor_trail_size = 0.4

	local default_scale = 1.38
	vim.g.neovide_scale_factor = default_scale

	vim.api.nvim_set_keymap(
		"n",
		"<C-=>",
		":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor + 0.1<CR>",
		{ silent = true }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<C-->",
		":lua vim.g.neovide_scale_factor = vim.g.neovide_scale_factor - 0.1<CR>",
		{ silent = true }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<C-0>",
		":lua vim.g.neovide_scale_factor = " .. default_scale .. "<CR>",
		{ silent = true }
	)
end

vim.api.nvim_create_autocmd('TextYankPost', {
	callback = function()
		vim.highlight.on_yank({ timeout = 90 })
	end,
})

vim.api.nvim_create_autocmd('InsertEnter', {
	callback = function()
		vim.opt.relativenumber = false
	end,
})
vim.api.nvim_create_autocmd('InsertLeave', {
	callback = function()
		vim.opt.relativenumber = true
	end,
})
