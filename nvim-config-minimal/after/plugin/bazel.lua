local function bazel_debug_lldb(callback)
	local bazel = require("bazel")
	bazel.get_target_list(function(targets)
		vim.ui.select(targets, {
			prompt = "Select target to debug",
			format_item = function(target)
				return target.label .. " (" .. target.kind .. ")"
			end,
		}, function(target)
			bazel.target_executable_path("@llvm_toolchain_llvm//:bin/lldb-dap", function(lldb_dap_path)
				--- @type dap.ExecutableAdapter
				local adapter = {
					type = "executable",
					command = lldb_dap_path,
					name = "lldb",
					args = {},
				}

				callback(target, adapter)
			end)
		end)
	end)
end

local function bazel_debug_launch()
	bazel_debug_lldb(function(target, adapter)
		local bazel = require("bazel")
		local dap = require("dap")

		bazel.info({ "execution_root", "workspace" }, function(info)
			bazel.target_executable_path(target.label, function(target_executable_path)
				--- @type dap.Configuration
				local config = {
					name = target.label,
					type = "lldb",
					request = "launch",
					program = info.execution_root .. "/" .. target_executable_path,
					cwd = info.workspace,
					stopOnEntry = false,
					args = {},
					initCommands = {
						"process handle -s false -n false SIGWINCH",
					},
					preRunCommands = {
						"settings set target.language c++20",
						"breakpoint set -E c++ -G true",
						"settings set target.auto-source-map-relative true",
						"settings set target.source-map . " .. info.workspace .. " /proc/self/cwd " .. info.workspace,
					},
				}

				dap.launch(adapter, config, {})
			end)
		end)
	end)
end

local function bazel_debug_attach()
	bazel_debug_lldb(function(target, adapter)
		local bazel = require("bazel")
		local dap = require("dap")

		bazel.info({ "execution_root", "workspace" }, function(info)
			bazel.target_executable_path(target.label, function(target_executable_path)
				--- @type dap.Configuration
				local config = {
					name = target.label,
					type = "lldb",
					request = "attach",
					waitFor = true,
					program = info.execution_root .. "/" .. target_executable_path,
					cwd = info.workspace,
					stopOnEntry = false,
					args = {},
					initCommands = {
						"process handle -s false -n false SIGWINCH",
					},
					preRunCommands = {
						"settings set target.language c++20",
						"breakpoint set -E c++ -G true",
						"settings set target.auto-source-map-relative true",
						"settings set target.source-map . " .. info.workspace .. " /proc/self/cwd " .. info.workspace,
					},
				}

				dap.launch(adapter, config, {})
			end)
		end)
	end)
end

vim.api.nvim_create_user_command("BazelDebug", bazel_debug_launch, {})
vim.api.nvim_create_user_command("BazelDebugAttachWait", bazel_debug_attach, {})

local bazel_group = vim.api.nvim_create_augroup("BazelRefresh", { clear = true })
local refresh_timer

vim.api.nvim_create_autocmd("BufWritePre", {
	group = bazel_group,
	pattern = "*.bazel",
	callback = function()
		local filepath = vim.api.nvim_buf_get_name(0)
		if vim.fn.filereadable(filepath) == 1 then
			vim.b.bazel_pre_hash = vim.fn.sha256(table.concat(vim.fn.readfile(filepath), "\n"))
		else
			vim.b.bazel_pre_hash = ""
		end
	end,
})

vim.api.nvim_create_autocmd("BufWritePost", {
	group = bazel_group,
	pattern = "*.bazel",
	callback = function(ev)
		if refresh_timer then
			refresh_timer:stop()
			if not refresh_timer:is_closing() then
				refresh_timer:close()
			end
		end

		refresh_timer = vim.uv.new_timer()
		assert(refresh_timer)
		refresh_timer:start(
			500,
			0,
			vim.schedule_wrap(function()
				if refresh_timer then
					if not refresh_timer:is_closing() then
						refresh_timer:close()
					end
					refresh_timer = nil
				end

				local filepath = vim.api.nvim_buf_get_name(ev.buf)
				local current_hash = ""
				if vim.fn.filereadable(filepath) == 1 then
					current_hash = vim.fn.sha256(table.concat(vim.fn.readfile(filepath), "\n"))
				end

				local pre_hash = ""
				local ok, val = pcall(vim.api.nvim_buf_get_var, ev.buf, "bazel_pre_hash")
				if ok then
					pre_hash = val
				end

				if pre_hash == current_hash then
					return
				end

				local fidget = require("fidget")
				local progress = fidget.progress.handle.create({
					title = "//bazel/dev:refresh_compile_commands",
					lsp_client = { name = "zaucy bazel.lua" },
					message = "bazel run",
				})

				local stdout = vim.uv.new_pipe(false)
				assert(stdout)

				local handle

				handle = vim.uv.spawn("bazel", {
					args = { "run", "//bazel/dev:refresh_compile_commands" },
					cwd = vim.uv.cwd(),
					stdio = { nil, stdout, nil },
				}, function(code)
					stdout:read_stop()

					stdout:close()

					if handle then
						handle:close()
					end

					vim.schedule(function()
						if code ~= 0 then
							progress.message = "refresh failed (code: " .. tostring(code) .. ")"
							progress:cancel()
						else
							progress:finish()
							vim.cmd("lsp restart clangd")
						end
					end)
				end)

				vim.uv.read_start(stdout, function(err, data)
					if not err and data then
						local lines = vim.split(data, "\n", { trimempty = true })

						if #lines > 0 then
							local last_line = vim.trim(lines[#lines])

							vim.schedule(function()
								progress:report({
									title = "//bazel/dev:refresh_compile_commands",
									lsp_client = { name = "zaucy bazel.lua" },
									message = last_line,
								})
							end)
						end
					end
				end)
			end)
		)
	end,
})
