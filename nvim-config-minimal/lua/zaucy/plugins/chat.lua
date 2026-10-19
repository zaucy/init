require("zaucy.chat").setup({
	chat_scratch_dir = vim.fn.substitute(vim.fn.expand("~/projects/zaucy/init/scratch/chat"), "\\\\", "/", "g"),
	chat = {
		type = "buffer",
		cmd = ":e agy://",
		mode = "normal",
	},
	cwd = function(dir)
		dir = dir:gsub("\\", "/")
		if vim.startswith(dir, "C:/d") then
			return { type = "terminal", cmd = "claude" }
		end
		return { type = "buffer", cmd = ":e agy://" }
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = { "ZaucyChatTerminalBufCreated", "ZaucyChatBufCreated" },
	callback = function(args)
		local bufnr = args.data.terminal_bufnr or args.data.bufnr

		if args.data.terminal_bufnr then
			vim.keymap.set({ "t" }, "<C-S-CR>", function()
				vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
				require("zaucy.chat").chat_hide()
			end, { buffer = bufnr })

			local forwarded_keys = {
				"<C-d>",
				"<C-u>",
			}

			for _, key in ipairs(forwarded_keys) do
				vim.keymap.set({ "t" }, key, "<C-\\><C-n>" .. key, { buffer = bufnr, remap = true })
			end
		end

		vim.keymap.set({ "t", "n", "v" }, "<C-g>", function()
			require("zaucy.chat").chat_hide()
		end, { buffer = bufnr })
	end,
})
