local function type_anim_command(opts)
	local win = vim.api.nvim_get_current_win()
	local buf = vim.api.nvim_get_current_buf()
	local original_lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	local lines = { "" }
	local curr_row = 0
	local curr_col = 0

	vim.api.nvim_buf_set_lines(buf, 0, -1, false, {})
	vim.api.nvim_command("")

	vim.cmd('startinsert')
	local timer = vim.loop.new_timer()
	timer:start(100, 16, vim.schedule_wrap(function()
		xpcall(function()
			local original_line = original_lines[curr_row + 1]
			if original_line == nil then
				timer:close()
				return
			end
			if curr_col > #original_line then
				curr_col = 0
				curr_row = curr_row + 1
				table.insert(lines, "")
				if curr_row > #original_lines then
					timer:close()
					return
				end
			end
			local curr_char = string.sub(original_line, curr_col, curr_col)
			lines[curr_row + 1] = lines[curr_row + 1] .. curr_char
			vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
			vim.api.nvim_win_set_cursor(win, { curr_row + 1, curr_col + 1 })
			curr_col = curr_col + 1
		end, function(err)
			timer:close()
			print(err)
		end)
	end))
end

if not vim.g.vscode then
	vim.api.nvim_create_user_command("TypeAnim", type_anim_command, {})
end
