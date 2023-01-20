local M = {}

function M.buildifier()
end

vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("ZaucyBazelBufWritePre", { clear = true }),
	pattern = { "*.bazel", "*.bzl", "WORKSPACE", "BUILD" },
	-- command = "%!buildifier",
	callback = function(data)
		local cursor_pos = vim.api.nvim_win_get_cursor(0)
		local output = vim.fn.systemlist("buildifier", data.buf)

		if vim.v.shell_error == 0 then
			vim.api.nvim_buf_set_lines(data.buf, 0, -1, false, output)
		else
			for _, line in ipairs(output) do
				print(line)
			end
		end

		vim.api.nvim_win_set_cursor(0, cursor_pos)
	end,
})

return M
