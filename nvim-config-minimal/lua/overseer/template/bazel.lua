return {
	cache_key = function(_)
		return vim.fs.normalize(vim.uv.cwd() .. "/MODULE.bazel")
	end,
	condition = {
		callback = function(_)
			local module_path = vim.fs.normalize(vim.uv.cwd() .. "/MODULE.bazel")
			local stat = vim.uv.fs_stat(module_path)
			return (stat and stat.type == 'file')
		end,
	},
	generator = function(_, callback)
		local bazel = require('bazel')
		bazel.get_target_list(function(targets)
			local templates = vim.tbl_map(function(target)
				local params_scheme = {
					subcommand = {
						type = "enum",
						choices = { "build", "run" },
						default = "run",
					},
					args = {
						type = "list",
						subtype = {
							type = "string",
						},
						default = {},
					},
				}

				if vim.endswith(target.kind, "_test") then
					table.insert(params_scheme.subcommand.choices, 1, "test")
					params_scheme.subcommand.default = "test"
				end

				return {
					name = " " .. target.label .. " (" .. target.kind .. ")",
					params = params_scheme,
					builder = function(params)
						local cmd = { "bazel", params.subcommand or default_subcommand, target.label }

						if #params.args > 0 then
							table.insert(cmd, "--")
							for _, arg in ipairs(params.args) do
								table.insert(cmd, arg)
							end
						end

						return {
							cmd = cmd,
						}
					end,
				}
			end, targets)

			table.insert(templates, 1, {
				name = " //...",
				params = {
					subcommand = {
						type = "enum",
						choices = { "build", "test" },
						default = "build",
					},
				},
				builder = function(params)
					return { cmd = { "bazel", params.subcommand or "build", "//..." } }
				end,
			})

			callback(templates)
		end)
	end,
}
