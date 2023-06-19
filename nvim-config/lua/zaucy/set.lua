vim.g.mapleader = " "

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.smartindent = true
vim.opt.cursorline = true
vim.opt.list = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.autoread = true
vim.opt.signcolumn = 'yes'
vim.opt.colorcolumn = "80"
vim.opt.listchars = {
	lead = '.',
	trail = '.',
	tab = '⇥ ',
}

-- I'm using nathom/filetype.nvim
vim.g.did_load_filetypes = 1

-- netrw settings
vim.g.netrw_keepdir = 0

-- lsp, yo
vim.lsp.set_log_level("off")
