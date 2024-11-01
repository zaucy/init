local function bazel_debug_lldb(callback)
	local bazel = require('bazel')
	bazel.get_target_list(function(targets)
		vim.ui.select(targets, {
			prompt = 'Select target to debug',
			format_item = function(target)
				return target.label .. " (" .. target.kind .. ")"
			end
		}, function(target)
			bazel.target_executable_path('@llvm_toolchain_llvm//:bin/lldb-dap', function(lldb_dap_path)
				--- @type dap.ExecutableAdapter
				local adapter = {
					type = 'executable',
					command = lldb_dap_path,
					name = 'lldb',
					args = {},
				}

				callback(target, adapter)
			end)
		end)
	end)
end

local function bazel_debug_launch()
	bazel_debug_lldb(function(target, adapter)
		local bazel = require('bazel')
		local dap = require('dap')

		bazel.info({ "execution_root", "workspace" }, function(info)
			bazel.target_executable_path(target.label, function(target_executable_path)
				--- @type dap.Configuration
				local config = {
					name = target.label,
					type = "lldb",
					request = "launch",
					program = info.execution_root .. '/' .. target_executable_path,
					cwd = info.workspace,
					stopOnEntry = false,
					args = {},
					initCommands = {
						'process handle -s false -n false SIGWINCH',
					},
					preRunCommands = {
						'settings set target.language c++20',
						'breakpoint set -E c++ -G true',
						'settings set target.auto-source-map-relative true',
						'settings set target.source-map . ' ..
						info.workspace .. ' /proc/self/cwd ' .. info.workspace,
					},
				}

				dap.launch(adapter, config, {})
			end)
		end)
	end)
end

local function bazel_debug_attach()
	bazel_debug_lldb(function(target, adapter)
		local bazel = require('bazel')
		local dap = require('dap')

		bazel.info({ "execution_root", "workspace" }, function(info)
			bazel.target_executable_path(target.label, function(target_executable_path)
				--- @type dap.Configuration
				local config = {
					name = target.label,
					type = "lldb",
					request = "attach",
					waitFor = true,
					program = info.execution_root .. '/' .. target_executable_path,
					cwd = info.workspace,
					stopOnEntry = false,
					args = {},
					initCommands = {
						'process handle -s false -n false SIGWINCH',
					},
					preRunCommands = {
						'settings set target.language c++20',
						'breakpoint set -E c++ -G true',
						'settings set target.auto-source-map-relative true',
						'settings set target.source-map . ' ..
						info.workspace .. ' /proc/self/cwd ' .. info.workspace,
					},
				}

				dap.launch(adapter, config, {})
			end)
		end)
	end)
end

vim.api.nvim_create_user_command("BazelDebug", bazel_debug_launch, {})
vim.api.nvim_create_user_command("BazelDebugAttachWait", bazel_debug_attach, {})
