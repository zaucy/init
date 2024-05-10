return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        cs = { "lsp" },
        starlark = { "buildifier" },
        bzl = { "buildifier" },
      },
    },
  },
}
