return {
	{
		"stevearc/conform.nvim",
		opts = {
			format_on_save = {
				lsp_format = "fallback",
				timeout_ms = 500,
			},
			formatters_by_ft = {
				cs = { "lsp", "clang-format" },
				starlark = { "buildifier" },
				bzl = { "buildifier" },
				javascript = { { "prettierd", "prettier" } },
				typescript = { { "prettierd", "prettier" } },
				typescriptreact = { { "prettierd", "prettier" } },
				json = { { "prettierd", "prettier" } },
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
