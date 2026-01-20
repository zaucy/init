local function c_cpp_formatter(bufnr)
	local root = vim.fs.root(bufnr, ".git")
	local basename = vim.fs.basename(root)

	if basename == "raddebugger" then
		-- raddebugger has some insane formatting, do not autoformat
		return {}
	end

	return { "clang-format" }
end

return {
	{
		"stevearc/conform.nvim",
		opts = {
			async = true,
			format_on_save = {
				lsp_format = "fallback",
				timeout_ms = 500,
			},
			formatters_by_ft = {
				c = c_cpp_formatter,
				cpp = c_cpp_formatter,
				cs = function(bufnr)
					local root = vim.fs.root(bufnr, ".git")
					if vim.fs.basename(root) == "ecsact_unity" then
						return { "clang-format" }
					end
					return nil
				end,
				shaderslang = { "clang-format" },
				starlark = { "buildifier" },
				bzl = { "buildifier" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				lua = { "stylua" },
			},
		},
	},
	{
		"zapling/mason-conform.nvim",
		dependencies = {
			"stevearc/conform.nvim",
		},
	},
}
