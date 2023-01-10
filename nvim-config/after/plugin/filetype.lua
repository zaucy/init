require("filetype").setup {
	extensions = {
		bazel = "bazel",
		bzl = "bazel",
		ecsact = "ecsact",
	},
	literal = {
		WORKSPACE = "bazel",
		BUILD = "bazel",
	},
	overrides = {
		ecsact = "ecsact",
	},
}
