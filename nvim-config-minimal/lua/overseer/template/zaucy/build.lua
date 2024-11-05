return {
	name = "Build Game",
	cache_key = function(_)
		return vim.fs.normalize(vim.uv.cwd() .. "/build.nu")
	end,
	condition = {
		callback = function(_)
			local module_path = vim.fs.normalize(vim.uv.cwd() .. "/build.nu")
			local stat = vim.uv.fs_stat(module_path)
			return (stat and stat.type == 'file')
		end,
	},
	builder = function()
		return {
			cmd = { "nu", "build.nu" },
		}
	end
}
