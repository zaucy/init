return {
	name = "Play Game",
	cache_key = function(_)
		return vim.fs.normalize(vim.uv.cwd() .. "/play.nu")
	end,
	condition = {
		callback = function(_)
			local module_path = vim.fs.normalize(vim.uv.cwd() .. "/play.nu")
			local stat = vim.uv.fs_stat(module_path)
			return (stat and stat.type == 'file')
		end,
	},
	builder = function()
		return {
			cmd = { "nu", "play.nu" },
		}
	end
}
