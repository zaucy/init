local nnoremap = require("zaucy.keymap").nnoremap

nnoremap("<C-d>", "<C-d>zz")
nnoremap("<C-u>", "<C-u>zz")
nnoremap("n", "nzzzv")
nnoremap("N", "Nzzzv")
nnoremap("<C-S-e>", ":NvimTreeFindFile<CR>")

vim.api.nvim_set_keymap(
	"n",
	"<C-\\>",
	":ToggleTerm<CR>",
	{ noremap = true }
)
