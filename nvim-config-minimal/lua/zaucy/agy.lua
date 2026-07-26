local M = {}

M.active_jobs = {}

local message_handlers = {
	line_message = function(json, ctx)
		if not json.line or not json.msg then
			return
		end

		local opts = {
			bufnr = ctx.bufnr,
			ns = ctx.response_ns,
			connector_ns = ctx.connector_ns,
			line = json.line,
			end_line = json.end_line,
			msg = json.msg,
			tail_msg = json.tail_msg,
			hl_group = json.hl_group,
			title = "󰚩 󰭹 ",
		}

		local buffer_message = require("zaucy.buffer_message")
		buffer_message.add_buffer_message(opts)
	end,
	highlight = function(json, ctx)
		if not json.line then
			return
		end
		local lnum = math.max(0, json.line - 1)
		pcall(vim.api.nvim_buf_set_extmark, ctx.bufnr, ctx.highlight_ns, lnum, 0, {
			line_hl_group = json.hl_group or "Visual",
		})
	end,
	selection = function(json, ctx)
		if not (json.start_line and json.end_line and json.start_col and json.end_col) then
			return
		end
		local start_row = math.max(1, json.start_line)
		local end_row = math.max(1, json.end_line)
		local start_col = math.max(0, json.start_col - 1)
		local end_col = math.max(0, json.end_col - 1)
		pcall(vim.cmd, 'execute "normal! \\<Esc>"')
		pcall(vim.api.nvim_win_set_cursor, 0, { start_row, start_col })
		pcall(vim.cmd, "normal! v")
		pcall(vim.api.nvim_win_set_cursor, 0, { end_row, end_col })
	end,
	notify = function(json, ctx)
		if not json.msg then
			return
		end
		local level = vim.log.levels.INFO
		if json.level == "warn" then
			level = vim.log.levels.WARN
		elseif json.level == "error" then
			level = vim.log.levels.ERROR
		end
		vim.notify("agy: " .. json.msg, level)
	end,
}

--- Clears all agy indicators and response extmarks in the current buffer.
function M.clear()
	local bufnr = vim.api.nvim_get_current_buf()
	local response_ns = vim.api.nvim_create_namespace("agy_responses")
	local highlight_ns = vim.api.nvim_create_namespace("agy_highlights")
	local connector_ns = vim.api.nvim_create_namespace("agy_connectors")
	vim.api.nvim_buf_clear_namespace(bufnr, response_ns, 0, -1)
	vim.api.nvim_buf_clear_namespace(bufnr, highlight_ns, 0, -1)
	vim.api.nvim_buf_clear_namespace(bufnr, connector_ns, 0, -1)

	pcall(function()
		require("zaucy.buffer_message").clear(bufnr)
	end)

	local ok, b_vars = pcall(vim.api.nvim_buf_get_var, bufnr, "agy_orig_statuscolumn")
	if ok then
		pcall(vim.api.nvim_set_option_value, "statuscolumn", b_vars, { buf = bufnr })
		pcall(vim.api.nvim_buf_del_var, bufnr, "agy_orig_statuscolumn")
	end

	for _, win in ipairs(vim.api.nvim_list_wins()) do
		if vim.api.nvim_win_get_buf(win) == bufnr then
			local w_ok, w_vars = pcall(vim.api.nvim_win_get_var, win, "agy_orig_statuscolumn")
			if w_ok then
				pcall(vim.api.nvim_set_option_value, "statuscolumn", w_vars, { win = win })
				pcall(vim.api.nvim_win_del_var, win, "agy_orig_statuscolumn")
			end
		end
	end
end

--- Navigates the cursor to the next agy response highlight in the current buffer.
function M.goto_next()
	local bufnr = vim.api.nvim_get_current_buf()
	local ns = vim.api.nvim_create_namespace("agy_responses")
	local cursor = vim.api.nvim_win_get_cursor(0)
	local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, { cursor[1] - 1, cursor[2] + 1 }, { -1, -1 }, { limit = 1 })
	if #marks > 0 then
		vim.api.nvim_win_set_cursor(0, { marks[1][2] + 1, marks[1][3] })
	else
		vim.notify("No next Agy message", vim.log.levels.INFO)
	end
end

--- Navigates the cursor to the previous agy response highlight in the current buffer.
function M.goto_prev()
	local bufnr = vim.api.nvim_get_current_buf()
	local ns = vim.api.nvim_create_namespace("agy_responses")
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1] - 1
	local col = cursor[2]
	local start_pos
	if col > 0 then
		start_pos = { row, col - 1 }
	elseif row > 0 then
		start_pos = { row - 1, 2147483647 }
	else
		vim.notify("No previous Agy message", vim.log.levels.INFO)
		return
	end

	local marks = vim.api.nvim_buf_get_extmarks(bufnr, ns, start_pos, { 0, 0 }, { limit = 1, reverse = true })
	if #marks > 0 then
		vim.api.nvim_win_set_cursor(0, { marks[1][2] + 1, marks[1][3] })
	else
		vim.notify("No previous Agy message", vim.log.levels.INFO)
	end
end

--- Prompts the user for input and executes an asynchronous agy CLI command.
function M.prompt_agy()
	local bufnr = vim.api.nvim_get_current_buf()

	if vim.bo[bufnr].buftype ~= "" or vim.api.nvim_buf_get_name(bufnr) == "" then
		vim.notify("Agy requires a saved file on disk to make edits.", vim.log.levels.WARN)
		return
	end

	local mode = vim.fn.mode()
	local is_visual = mode == "v" or mode == "V" or mode == "\22"

	local context_text = ""
	if is_visual then
		local v_start = vim.fn.getpos("v")
		local v_end = vim.fn.getpos(".")
		local v_start_row = math.min(v_start[2], v_end[2])
		local v_end_row = math.max(v_start[2], v_end[2])
		local lines = vim.api.nvim_buf_get_lines(bufnr, v_start_row - 1, v_end_row, false)
		local numbered_lines = {}
		for i, line in ipairs(lines) do
			table.insert(numbered_lines, string.format("%d: %s", v_start_row - 1 + i, line))
		end
		context_text = "Here is my visually selected text:\n```\n" .. table.concat(numbered_lines, "\n") .. "\n```\n"
	end

	local user_input = vim.fn.input("Agy prompt: ")
	if user_input == "" then
		return
	end

	M.clear()

	local start_row, start_col = unpack(vim.api.nvim_win_get_cursor(0))
	start_row = start_row - 1 -- API uses 0-indexed rows

	local filetype = vim.bo[bufnr].filetype
	local relative_path = vim.fn.expand("%:p")

	local context_prompt = string.format(
		"I am editing a %s file at %s.\n%s"
			.. "You can make any necessary edits to the file using your tools.\n"
			.. "For your stdout response, output ONLY a stream of JSON Lines (one valid JSON object per line) to provide visual feedback in Neovim while you work. "
			.. "Do not output any markdown formatting or normal text. "
			.. "Be strategic about where you place these visuals. Put them on lines relevant to your thought process or edits, rather than just where the cursor is. You do not need to add virtual text just to explain edits, but you should definitely use highlights to draw attention to edits or important areas of the code.\n"
			.. "NOTE ON VIRTUAL TEXT: Virtual text is just an editor UI overlay. It does NOT modify the underlying file text or change line numbers. Do NOT attempt to highlight or select your own virtual text. Highlights and selections must only target the actual code lines.\n"
			.. "IMPORTANT INDEXING RULES: ALL lines and columns you output in the JSON MUST be strictly 1-indexed (e.g. line 1, column 1 is the very first character).\n"
			.. "Supported JSON objects:\n"
			.. '- `{"type": "line_message", "line": number, "msg": "string", "end_line": number, "tail_msg": "string", "hl_group": "string"}`: Adds a bordered message above the given line. If `end_line` is provided, the message visually spans multiple lines, closing after `end_line`. Omit `tail_msg` unless a closing remark is strictly necessary.\n'
			.. '- `{"type": "highlight", "line": number, "hl_group": "string"}`: Highlights the given line.\n'
			.. '- `{"type": "selection", "start_line": number, "end_line": number, "start_col": number, "end_col": number}`: Highlights a character range using visual mode. Use this sparingly, only when you specifically need the user to take action on a selection.\n'
			.. '- `{"type": "notify", "msg": "string", "level": "info|warn|error"}`: Displays a notification message.\n\n'
			.. "---\n"
			.. "My cursor is on line %d.\n"
			.. "Please fulfill this request: %s",
		filetype,
		relative_path,
		context_text,
		start_row + 1,
		user_input
	)

	local response_ns = vim.api.nvim_create_namespace("agy_responses")
	local highlight_ns = vim.api.nvim_create_namespace("agy_highlights")
	local connector_ns = vim.api.nvim_create_namespace("agy_connectors")

	require("zaucy.buffer_message") -- Ensures _G._agy_statuscolumn is defined
	local win = vim.api.nvim_get_current_win()
	local ok, orig_stc = pcall(vim.api.nvim_get_option_value, "statuscolumn", { win = win })
	if ok then
		local has_orig = pcall(vim.api.nvim_win_get_var, win, "agy_orig_statuscolumn")
		if not has_orig then
			pcall(vim.api.nvim_win_set_var, win, "agy_orig_statuscolumn", orig_stc)
		end
		pcall(vim.api.nvim_set_option_value, "statuscolumn", "%!v:lua._agy_statuscolumn()", { win = win })
	end

	local fidget_ok, fidget_progress = pcall(require, "fidget.progress")
	local progress_handle
	if fidget_ok then
		progress_handle = fidget_progress.handle.create({
			title = "󰚩 waiting for agy",
			lsp_client = { name = "agy" },
		})
	end

	local current_line = ""

	local job_id = vim.fn.jobstart({
		"agy",
		"--model=gemini-3.6-flash",
		"--effort=low",
		"-p",
		context_prompt,
	}, {
		stdout_buffered = false,
		on_stdout = function(_, data)
			if not data then
				return
			end
			-- Handle partial lines synchronously to avoid race conditions
			data[1] = current_line .. data[1]
			current_line = data[#data]
			table.remove(data, #data)

			if #data == 0 then
				return
			end

			local lines_to_process = data

			vim.schedule(function()
				if not vim.api.nvim_buf_is_valid(bufnr) then
					return
				end
				for _, line in ipairs(lines_to_process) do
					if line ~= "" then
						-- Parse JSON line
						local ok, json = pcall(vim.json.decode, line)
						if ok and type(json) == "table" and json.type then
							local handler = message_handlers[json.type]
							if handler then
								handler(json, {
									bufnr = bufnr,
									response_ns = response_ns,
									highlight_ns = highlight_ns,
									connector_ns = connector_ns,
								})
							end
						end
					end
				end
			end)
		end,
		on_stderr = function(_, data)
			if data then
				local err_msg = table.concat(data, "\n")
				if err_msg:match("%S") then
					vim.schedule(function()
						vim.notify("agy error: " .. err_msg, vim.log.levels.ERROR)
					end)
				end
			end
		end,
		on_exit = function(_, code)
			vim.schedule(function()
				if progress_handle then
					progress_handle:finish()
					progress_handle = nil
				end
				-- Refresh the buffer after agy makes edits
				if vim.api.nvim_buf_is_valid(bufnr) then
					vim.cmd("checktime " .. bufnr)
				end
			end)
		end,
	})

	M.active_jobs[job_id] = true
end

return M
