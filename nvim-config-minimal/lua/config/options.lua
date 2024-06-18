vim.g.mapleader = "<space>"
vim.g.maplocalleader = "\\"

vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true

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
