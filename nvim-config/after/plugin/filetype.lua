require("filetype").setup {
	extensions = {
		bazel = "bazel",
		bzl = "bazel",
		ecsact = "ecsact",
		html = "html",
	},
	literal = {
		WORKSPACE = "bazel",
		BUILD = "bazel",
	},
	overrides = {
		ecsact = "ecsact",
	},
}
