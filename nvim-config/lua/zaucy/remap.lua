local nnoremap = require("zaucy.keymap").nnoremap

nnoremap("<C-d>", "<C-d>zz")
nnoremap("<C-u>", "<C-u>zz")
nnoremap("n", "nzzzv")
nnoremap("N", "Nzzzv")
nnoremap("<C-S-e>", ":NvimTreeFocus<CR>")
nnoremap("<C-S-0>", ":NvimTreeFindFile<CR>")

vim.api.nvim_set_keymap(
  "n",
  "<leader>t",
  ":Telescope<CR>",
  { noremap = true }
)

vim.api.nvim_set_keymap(
  "n",
  "<leader>fd",
  ":Telescope fd<CR>",
  { noremap = true }
)

