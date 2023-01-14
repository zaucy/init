local M = {}

function M.buildifier()
end

vim.api.nvim_create_autocmd("BufWritePre", {
	pattern = { "*.bazel", "*.bzl", "WORKSPACE", "BUILD" },
	-- command = "%!buildifier",
	callback = function(data)
		local cursor_pos = vim.api.nvim_win_get_cursor(0)
		vim.api.nvim_command("%!buildifier")
		vim.api.nvim_win_set_cursor(0, cursor_pos)
	end,
})

return M
