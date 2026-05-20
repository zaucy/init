require("zaucy.chat").setup({
	chat_scratch_dir = vim.fn.substitute(vim.fn.expand("~/projects/zaucy/init/scratch/chat"), "\\\\", "/", "g"),
	terminal_command = "agy",
})

vim.api.nvim_create_autocmd("User", {
	pattern = "ZaucyChatTerminalBufCreated",
	callback = function(args)
		vim.keymap.set({ "t" }, "<C-S-CR>", function()
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
			require("zaucy.chat").chat_hide()
		end, { buffer = args.data.terminal_bufnr })

		vim.keymap.set({ "t", "n", "v" }, "<C-g>", function()
			require("zaucy.chat").chat_hide()
		end, { buffer = args.data.terminal_bufnr })

		local forwarded_keys = {
			"<C-d>",
			"<C-u>",
		}

		for _, key in ipairs(forwarded_keys) do
			vim.keymap.set({ "t" }, key, "<C-\\><C-n>" .. key, { buffer = args.data.terminal_bufnr, remap = true })
		end
	end,
})
