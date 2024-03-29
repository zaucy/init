local nnoremap = require("zaucy.keymap").nnoremap

nnoremap("<C-d>", "<C-d>zz")
nnoremap("<C-u>", "<C-u>zz")
nnoremap("j", "jzz")
nnoremap("k", "kzz")
nnoremap("n", "nzzzv")
nnoremap("N", "Nzzzv")

nnoremap("[qf", ":cprevious<CR>")
nnoremap("]qf", ":cnext<CR>")

vim.keymap.set(
	"n",
	"<M-1>",
	function()
		require('toggleterm').toggle_command(nil, 1)
	end
)

vim.keymap.set(
	"t",
	"<M-1>",
	function()
		require('toggleterm').toggle_command(nil, 1)
	end
)

vim.keymap.set(
	"n",
	"<M-2>",
	function()
		require('toggleterm').toggle_command(nil, 2)
	end
)

vim.keymap.set(
	"t",
	"<M-2>",
	function()
		require('toggleterm').toggle_command(nil, 2)
	end
)

vim.keymap.set(
	"n",
	"<M-3>",
	function()
		require('toggleterm').toggle_command(nil, 3)
	end
)

vim.keymap.set(
	"t",
	"<M-3>",
	function()
		require('toggleterm').toggle_command(nil, 3)
	end
)
