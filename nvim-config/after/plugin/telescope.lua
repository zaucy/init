require("telescope").setup {
	defaults = {
		file_ignore_patterns = {".git"},
	},
}

require("telescope").load_extension "gh"
require("telescope").load_extension "bazel"
