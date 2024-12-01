local M = {}

local function parse_pattern(pat_str)
	return pat_str or ""
end

local function parse_normal(norm_str)
	return norm_str or ""
end

local function parse_flags(flags_str)
	return flags_str
end

local function parse_cmd_str(cmd)
	if #cmd == 0 then return "", "", nil end
	local sep = cmd:sub(1, 1)
	local parts = vim.split(cmd:sub(2), sep, { plain = true })
	return parse_pattern(parts[1]), parse_normal(parts[2]), parse_flags(parts[3])
end

local function nos_preview(opts, preview_ns, preview_buf)
	local line1 = opts.line1
	local line2 = opts.line2
	local buf = vim.api.nvim_get_current_buf()

	local pat, norm, flags = parse_cmd_str(opts.args)
	if #pat == 0 then return 2 end

	while line1 ~= line2 do
		local line_iteration_count = 0
		local last_idx = 1
		while line_iteration_count < 32 do
			local line = vim.api.nvim_buf_get_lines(buf, line1 - 1, line1, false)[1]
			local start_idx, end_idx = string.find(line, pat, last_idx + 1)

			if not start_idx or not end_idx then break end

			vim.api.nvim_win_set_cursor(0, { line1, start_idx - 1 })

			if #norm == 0 then
				vim.api.nvim_buf_add_highlight(
					buf,
					preview_ns,
					'Visual',
					line1 - 1,
					start_idx,
					end_idx
				)
			else
				vim.cmd("normal! " .. norm)
			end

			local cursor_pos = vim.api.nvim_win_get_cursor(0)

			vim.api.nvim_buf_add_highlight(
				buf,
				preview_ns,
				'Cursor',
				cursor_pos[1] - 1,
				cursor_pos[2],
				cursor_pos[2] + 1
			)

			last_idx = cursor_pos[2] + 1
			line_iteration_count = line_iteration_count + 1
		end

		line1 = line1 + 1
	end

	return 2
end

local function nos_commit(opts)
	local line1 = opts.line1
	local line2 = opts.line2
	local buf = vim.api.nvim_get_current_buf()

	local pat, norm, flags = parse_cmd_str(opts.args)
	if #pat == 0 or #norm == 0 then return end

	while line1 ~= line2 do
		local line_iteration_count = 0
		local last_idx = 1
		while line_iteration_count < 32 do
			local line = vim.api.nvim_buf_get_lines(buf, line1 - 1, line1, false)[1]
			local start_idx, end_idx = string.find(line, pat, last_idx + 1)
			if not start_idx or not end_idx then break end
			vim.api.nvim_win_set_cursor(0, { line1, start_idx - 1 })
			vim.cmd("normal! " .. norm)
			local cursor_pos = vim.api.nvim_win_get_cursor(0)
			last_idx = cursor_pos[2] + 1
			line_iteration_count = line_iteration_count + 1
		end

		line1 = line1 + 1
	end
end

local function preview_with_error(preview_fn)
	return function(opts, preview_ns, preview_buf)
		local success, error_or_result = pcall(preview_fn, opts, preview_ns, preview_buf)
		if not success then
			local buf = vim.api.nvim_get_current_buf()
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Preview Function Failed", error_or_result })
			return 2
		end
		return error_or_result
	end
end

function M.setup(opts)
	vim.api.nvim_create_user_command("NOS", nos_commit, {
		nargs = "*",
		range = true,
		preview = preview_with_error(nos_preview),
	})

	function _G.NosOperatorFunc(motion_type)
		return M.operatorfunc(motion_type)
	end
end

function M.operatorfunc(motion_type)
	vim.cmd('normal! gv')
	vim.fn.feedkeys(':NOS/', 'n')
end

M.setup({})

return M
