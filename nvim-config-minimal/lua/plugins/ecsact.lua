vim.api.nvim_create_autocmd("FileType", {
	pattern = "ecsact",
	callback = function(args)
		vim.lsp.inlay_hint.enable(true, { bufnr = args.buf })
		vim.keymap.set({ "n" }, "gi", "<cmd>EcsactLspGotoImpl<cr>", { buffer = args.buf })

		-- ecsacts lsp is much faster than most so we just go immediately
		vim.keymap.set({ "n" }, "gd", vim.lsp.buf.definition, { buffer = args.buf })
	end,
})

return {
	"ecsact-dev/ecsact.nvim",
	dir = "~/projects/ecsact-dev/ecsact.nvim",
	lazy = false,
	opts = {},
}
