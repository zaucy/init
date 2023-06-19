local clang_callback_fmt_augroup = vim.api.nvim_create_augroup("ClangFallbackFormatting", {})

vim.api.nvim_clear_autocmds({ group = clang_callback_fmt_augroup })
vim.api.nvim_create_autocmd("BufWritePre", {
	group = clang_callback_fmt_augroup,
	pattern = { "*.cs" },
	callback = function()
		local util = require('lspconfig.util')
		if util.path.is_file('.clang-format') then
			local cursor_pos = vim.api.nvim_win_get_cursor(0);
			vim.cmd("%!clang-format --assume-filename=@% --style=file");
			vim.api.nvim_win_set_cursor(0, cursor_pos);
		end
	end,
})
