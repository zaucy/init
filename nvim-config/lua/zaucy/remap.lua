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

vim.api.nvim_set_keymap(
	"n",
	"<leader>ghp",
	":Telescope gh pull_request<CR>",
	{ noremap = true }
)

vim.api.nvim_set_keymap(
	"n",
	"<leader>ghi",
	":Telescope gh issuep<CR>",
	{ noremap = true }
)

for _, mode in ipairs({ "n", "i" }) do
	vim.api.nvim_set_keymap(
		mode,
		"<C-p>",
		"<Esc>:Telescope fd<CR>",
		{ noremap = true }
	)

	vim.api.nvim_set_keymap(
		mode,
		"<C-b>",
		"<Esc>:Telescope buffers theme=dropdown<CR>",
		{ noremap = true }
	)

	vim.keymap.set(
		mode,
		"<C-S-R>",
		function()
			require("telescope").extensions.vstask.tasks()
		end,
		{ noremap = true, expr = true }
	)

	vim.keymap.set(
		mode,
		"<F5>",
		function()
			require('dap.ext.vscode').load_launchjs(nil, { cppdbg = {'c', 'cpp'} })
			require('dap').continue()
		end,
		{ noremap = true, expr = true }
	)
	vim.keymap.set(
		mode,
		"<F10>",
		function()
			require('dap').step_over()
		end,
		{ noremap = true, expr = true }
	)
	vim.keymap.set(
		mode,
		"<F11>",
		function()
			require('dap').step_into()
		end,
		{ noremap = true, expr = true }
	)
	vim.keymap.set(
		mode,
		"<F12>",
		function()
			require('dap').step_out()
		end,
		{ noremap = true, expr = true }
	)
end

vim.keymap.set(
	"n",
	"<leader>git",
	function()
		print("TODO: open git stuff")
	end,
	{ noremap = true, expr = true }
)

vim.api.nvim_set_keymap(
	"n",
	"<leader>z",
	":Telescope zoxide list<CR>",
	{ noremap = true }
)
