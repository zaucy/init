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
				cs = function(bufnr)
					local root = vim.fs.root(bufnr, ".git")
					if vim.fs.basename(root) == "ecsact_unity" then
						return { "clang-format" }
					end
					return { "lsp" }
				end,
				shaderslang = { "clang-format" },
				starlark = { "buildifier" },
				bzl = { "buildifier" },
				javascript = { "prettierd", "prettier", stop_after_first = true },
				typescript = { "prettierd", "prettier", stop_after_first = true },
				typescriptreact = { "prettierd", "prettier", stop_after_first = true },
				json = { "prettierd", "prettier", stop_after_first = true },
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
