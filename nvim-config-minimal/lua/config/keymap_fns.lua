local M = {}

local function tonumber_safe(v)
	local _, n = pcall(tonumber, v)
	return n
end

function M.select_textobject(a, b)
	return function()
		return require("nvim-treesitter-textobjects.select").select_textobject(a, b)
	end
end

function M.goto_closest_file(filename)
	return function()
		local files = vim.fs.find(filename, {
			upward = true,
			path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
		})

		if #files > 0 then
			vim.cmd("e " .. files[1])
		end
	end
end

function M.bazel_override()
	vim.ui.input({}, function(input)
		if not input then
			return
		end
		M.goto_closest_file("MODULE.bazel")()
		vim.cmd("!bzloverride " .. input)
		vim.fn.feedkeys("G", "n")
	end)
end

function M.goto_bazel_file(path)
	if not path then
		path = vim.fn.expand("%")
	end

	require("bazel").info({}, function(info)
		local check_dirs = {
			info["bazel-bin"],
			info["execution_root"],
			info["output_base"],
			info["output_path"],
		}

		local found_files = {}

		for _, dir in ipairs(check_dirs) do
			local p = vim.fs.joinpath(dir, path)
			local p_dir = vim.fs.dirname(p)
			local stat = vim.uv.fs_stat(p_dir)

			if stat then
				table.insert(found_files, p_dir)
			end
		end

		if #found_files == 0 then
			vim.notify("couldn't find any bazel files for " .. path, vim.log.levels.ERROR)
		else
			vim.ui.select(found_files, {}, function(p)
				if not p then
					return
				end

				vim.cmd("e " .. p)
			end)
		end
	end)
end

function M.bzlmod_add()
	vim.ui.input({}, function(input)
		if not input then
			return
		end
		M.goto_closest_file("MODULE.bazel")()
		vim.cmd("!bzlmod add " .. input)
	end)
end

function M.do_fzf(cmd, opts)
	opts = opts or {}
	return function()
		local original_buf = vim.api.nvim_get_current_buf()
		local buf = vim.api.nvim_create_buf(true, false)
		vim.api.nvim_set_current_buf(buf)

		local fzf_cmd = { "fzf", "--no-mouse" }
		if opts.fzf_args then
			for _, arg in ipairs(opts.fzf_args) do
				table.insert(fzf_cmd, arg)
			end
		end

		local channel_id = vim.fn.jobstart(fzf_cmd, {
			term = true,
			stdout_buffered = false,
			cwd = opts.cwd,
			env = {
				FZF_DEFAULT_COMMAND = cmd,
				-- FZF_DEFAULT_OPTS = FZF_DEFAULT_OPTS,
			},
			on_exit = function(_, code, _)
				if code == 0 then
					local line = vim.api.nvim_buf_get_lines(buf, 0, -1, false)[1]:gsub("\\", "/")
					local info = vim.json.decode(line)
					local file_path = vim.fn.fnameescape(info.filename)
					local full_path = file_path
					if opts.cwd then
						full_path = vim.fs.joinpath(opts.cwd, file_path)
					end
					vim.cmd.edit(full_path)

					if info.line ~= nil or info.col ~= nil then
						local line_num = tonumber_safe(info.line) or 1
						local col_num = (tonumber_safe(info.col) or 1) - 1
						vim.api.nvim_win_set_cursor(0, { line_num, col_num })
					end
					vim.api.nvim_buf_delete(buf, { force = true, unload = true })
				elseif code == 130 then
					vim.api.nvim_set_current_buf(original_buf)
					vim.api.nvim_buf_delete(buf, { force = true, unload = true })
				end
			end,
		})

		if channel_id > 0 then
			vim.cmd.startinsert()
		end
	end
end

return M
