local bazel = require('bazel')

for _, mode in ipairs({ "n", "i" }) do
	vim.keymap.set(
		mode,
		"<C-S-D>",
		function()
			bazel.select_target({}, function(target)
				print(target)
			end)
		end,
		{ noremap = true, expr = true }
	)
end

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
