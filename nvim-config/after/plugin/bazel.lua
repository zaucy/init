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

