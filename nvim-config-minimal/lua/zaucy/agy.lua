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
--- @param opts? { continue_last?: boolean, prompt?: string }
function M.prompt_agy(opts)
	opts = opts or {}
	local continue_last = opts.continue_last or false
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

	local user_input = opts.prompt
	if not user_input or user_input == "" then
		local prompt_title = continue_last and "Agy continue: " or "Agy prompt: "
		user_input = vim.fn.input(prompt_title)
	end
	if not user_input or user_input == "" then
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

	local cmd = {
		"agy",
		"--model=gemini-3.8-flash",
		"--effort=low",
	}
	if continue_last then
		table.insert(cmd, "--continue")
	end
	table.insert(cmd, "-p")
	table.insert(cmd, context_prompt)

	local job_id = vim.fn.jobstart(cmd, {
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
						local p_ok, json = pcall(vim.json.decode, line)
						if p_ok and type(json) == "table" and json.type then
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

--- Continues the most recent buffer prompt turn.
--- @param opts? { prompt?: string }
function M.continue_agy(opts)
	opts = opts or {}
	opts.continue_last = true
	return M.prompt_agy(opts)
end

M.last_search = nil

--- Searches the entire workspace for matching concepts, patterns, or code shapes using Antigravity,
--- and progressively streams the matching slices and status into a multibuffer in real time.
--- @param opts? { continue_last?: boolean, query?: string }
function M.search_workspace(opts)
	opts = opts or {}
	local continue_last = opts.continue_last or false

	if continue_last and (not M.last_search or not M.last_search.conversation_id) then
		vim.notify("No previous Agy workspace search found to continue.", vim.log.levels.WARN)
		return
	end

	local mb_ok, multibuffer = pcall(require, "multibuffer")
	if not mb_ok then
		vim.notify("multibuffer.nvim is required for Agy workspace search", vim.log.levels.ERROR)
		return
	end

	local mode = vim.fn.mode()
	local is_visual = mode == "v" or mode == "V" or mode == "\22"
	local visual_context = ""
	local current_bufnr = vim.api.nvim_get_current_buf()
	local current_file = vim.api.nvim_buf_get_name(current_bufnr)

	if is_visual then
		local v_start = vim.fn.getpos("v")
		local v_end = vim.fn.getpos(".")
		local v_start_row = math.min(v_start[2], v_end[2])
		local v_end_row = math.max(v_start[2], v_end[2])
		local lines = vim.api.nvim_buf_get_lines(current_bufnr, v_start_row - 1, v_end_row, false)
		if #lines > 0 then
			local filetype = vim.bo[current_bufnr].filetype
			visual_context = string.format(
				"Reference code snippet from %s (lines %d-%d):\n```%s\n%s\n```\n",
				current_file ~= "" and current_file or "current buffer",
				v_start_row,
				v_end_row,
				filetype,
				table.concat(lines, "\n")
			)
		end
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
	end

	local user_input = opts.query
	if not user_input or user_input == "" then
		local prompt_title
		if continue_last then
			prompt_title = string.format("Agy refine search [%s]: ", M.last_search.query or "")
		elseif is_visual then
			prompt_title = "Agy concept search (matching selection): "
		else
			prompt_title = "Agy concept search: "
		end
		user_input = vim.fn.input(prompt_title)
	end

	if not user_input or user_input == "" then
		return
	end

	local full_query = user_input
	if continue_last and M.last_search and M.last_search.query then
		full_query = M.last_search.query .. " -> " .. user_input
	end

	local mbuf
	if continue_last and M.last_search and M.last_search.mbuf and vim.api.nvim_buf_is_valid(M.last_search.mbuf) then
		mbuf = M.last_search.mbuf
		multibuffer.win_set_multibuf(0, mbuf)
		multibuffer.multibuf_clear_bufs(mbuf)
	else
		mbuf = multibuffer.create_multibuf()
		multibuffer.win_set_multibuf(0, mbuf)
	end

	local all_matches = {}
	local final_summary = nil
	local current_action = "Initializing search..."
	local is_searching = true
	local activity_log = {}
	local total_actions = 0
	local has_moved_cursor = false

	local function add_activity_log(entry)
		if not entry or entry == "" then
			return
		end
		entry = tostring(entry):gsub("\r\n", " "):gsub("\n", " "):gsub("\r", " ")
		entry = vim.trim(entry)
		if #activity_log > 0 and activity_log[#activity_log] == entry then
			return
		end
		table.insert(activity_log, entry)
		total_actions = total_actions + 1
		if #activity_log > 30 then
			table.remove(activity_log, 1)
		end
	end

	local function add_header_entry(target, prefix, text)
		if not text or text == "" then
			return
		end
		text = tostring(text):gsub("\r\n", "\n"):gsub("\r", "\n")
		local lines = vim.split(text, "\n", { plain = true })
		for i, line in ipairs(lines) do
			line = vim.trim(line)
			if line ~= "" then
				if i == 1 then
					table.insert(target, prefix .. line)
				else
					table.insert(target, string.rep(" ", #prefix) .. line)
				end
			end
		end
	end

	local function render_header()
		local match_count = #all_matches
		local raw_header = {}

		add_header_entry(raw_header, " 󰚩 Agy Concept Search: ", full_query)

		if is_searching then
			table.insert(
				raw_header,
				string.format(
					" 󰑮 Searching workspace... | %d match%s | %d actions",
					match_count,
					match_count == 1 and "" or "es",
					total_actions
				)
			)
			if current_action and current_action ~= "" then
				add_header_entry(raw_header, " 󰋼 Current: ", current_action)
			end
		else
			table.insert(
				raw_header,
				string.format(
					" 󰄬 Search completed | %d match%s found across %d action%s",
					match_count,
					match_count == 1 and "" or "es",
					total_actions,
					total_actions == 1 and "" or "s"
				)
			)
			if final_summary and final_summary ~= "" then
				add_header_entry(raw_header, " 󰅩 Summary: ", final_summary)
			end
		end

		-- Live activity report (show recent 5 entries)
		if #activity_log > 0 then
			table.insert(raw_header, is_searching and " Live Search Report:" or " Search Activity:")
			local start_idx = math.max(1, #activity_log - 4)
			for i = start_idx, #activity_log do
				add_header_entry(raw_header, "   ", activity_log[i])
			end
		end

		if not is_searching and match_count > 0 then
			table.insert(raw_header, " Matched Locations:")
			local count = 0
			for _, match in ipairs(all_matches) do
				if count < 8 then
					local short = vim.fn.fnamemodify(match.file, ":~:.")
					local note_str = (match.note and match.note ~= "") and (" - " .. match.note) or ""
					add_header_entry(raw_header, "   • ", string.format("%s:%d%s", short, match.start_line, note_str))
					count = count + 1
				end
			end
		end

		table.insert(raw_header, "  <CR>: jump to source | <C-up>/<C-down>: expand slice | <leader>ar: refine search")
		table.insert(raw_header, string.rep("─", 75))
		table.insert(raw_header, "")

		-- Absolute guarantee: ensure NO element contains any newline character (\n or \r)
		local safe_header = {}
		for _, item in ipairs(raw_header) do
			if type(item) == "string" then
				local cleaned = item:gsub("\r\n", "\n"):gsub("\r", "\n")
				local split_lines = vim.split(cleaned, "\n", { plain = true })
				for _, sl in ipairs(split_lines) do
					table.insert(safe_header, sl)
				end
			end
		end

		return safe_header
	end

	multibuffer.multibuf_set_header(mbuf, render_header())

	local function refresh_multibuffer()
		if not vim.api.nvim_buf_is_valid(mbuf) then
			return
		end

		pcall(multibuffer.multibuf_set_header, mbuf, render_header())

		local add_opts_by_buf = {}
		local buf_order = {}

		for _, match in ipairs(all_matches) do
			if match.file and match.start_line then
				local file = match.file
				if vim.fn.filereadable(file) ~= 1 then
					local rel = vim.fn.getcwd() .. "/" .. file
					if vim.fn.filereadable(rel) == 1 then
						file = rel
					end
				end

				local full_path = vim.fs and vim.fs.normalize and vim.fs.normalize(vim.fn.fnamemodify(file, ":p"))
					or vim.fn.fnamemodify(file, ":p")

				if vim.fn.filereadable(full_path) == 1 then
					local bnr = vim.fn.bufadd(full_path)
					if vim.api.nvim_buf_is_valid(bnr) then
						if not vim.api.nvim_buf_is_loaded(bnr) then
							vim.fn.bufload(bnr)
						end

						if not add_opts_by_buf[bnr] then
							add_opts_by_buf[bnr] = {
								buf = bnr,
								regions = {},
							}
							table.insert(buf_order, bnr)
						end

						local line_count = vim.api.nvim_buf_line_count(bnr)
						local s_row = math.max(0, match.start_line - 1)
						local e_row = math.max(s_row, (match.end_line or match.start_line) - 1)
						if line_count > 0 then
							s_row = math.min(s_row, line_count - 1)
							e_row = math.min(e_row, line_count - 1)
						end

						table.insert(add_opts_by_buf[bnr].regions, {
							start_row = s_row,
							end_row = e_row,
						})
					end
				end
			end
		end

		local add_buf_opts = {}
		for _, bnr in ipairs(buf_order) do
			local b_opt = add_opts_by_buf[bnr]
			table.sort(b_opt.regions, function(a, b)
				return a.start_row < b.start_row
			end)

			local merged = {}
			for _, reg in ipairs(b_opt.regions) do
				if #merged == 0 then
					table.insert(merged, reg)
				else
					local last = merged[#merged]
					if reg.start_row <= last.end_row + 1 then
						last.end_row = math.max(last.end_row, reg.end_row)
					else
						table.insert(merged, reg)
					end
				end
			end
			b_opt.regions = merged
			table.insert(add_buf_opts, b_opt)
		end

		pcall(multibuffer.multibuf_clear_bufs, mbuf)
		pcall(multibuffer.multibuf_add_bufs, mbuf, add_buf_opts)

		if not has_moved_cursor and #buf_order > 0 then
			local first_bnr = buf_order[1]
			local first_region = add_opts_by_buf[first_bnr].regions[1]
			if first_region then
				local mb_line = multibuffer.multibuf_buf_get_line(mbuf, first_bnr, first_region.start_row)
				if mb_line then
					local cur_win = vim.api.nvim_get_current_win()
					if vim.api.nvim_win_get_buf(cur_win) == mbuf then
						pcall(vim.api.nvim_win_set_cursor, cur_win, { mb_line + 1, 0 })
						has_moved_cursor = true
					end
				end
			end
		end
	end

	local refresh_pending = false
	local function schedule_refresh()
		if refresh_pending then
			return
		end
		refresh_pending = true
		vim.schedule(function()
			refresh_pending = false
			refresh_multibuffer()
		end)
	end

	local streaming_rules = "CRITICAL INSTRUCTIONS FOR EARLY, PROGRESSIVE RESULTS:\n"
		.. "- EMIT MATCHES IMMEDIATELY: As soon as you inspect a file and determine it matches the requested concept, pattern, or code shape, output its `{\"type\": \"match\", ...}` JSON line IMMEDIATELY in that turn before or alongside calling any more tools.\n"
		.. "- DO NOT BATCH AT THE END: Do not wait until you have finished all your tool calls or finished inspecting every candidate file to emit matches. The user's editor dynamically renders each match slice the instant you output it.\n"
		.. "- PROGRESSIVE DISCOVERY: It is completely expected and encouraged to output matches one-by-one as you discover them across multiple steps while continuing your exploration.\n"
		.. "- FORMAT REQUIREMENTS: Output ONLY JSON Lines on stdout (one valid JSON object per line). Absolutely no markdown code fences (no ```json or ```).\n\n"
		.. "Supported JSON objects (one per line):\n"
		.. '- `{"type": "status", "msg": "Currently inspecting lua/..."}`\n'
		.. '- `{"type": "match", "file": "path/to/file.lua", "start_line": 10, "end_line": 25, "note": "Why this matches"}` (1-indexed line numbers)\n'
		.. '- `{"type": "summary", "text": "Overall conclusion across discovered patterns"}`'

	local context_prompt
	if continue_last then
		context_prompt = string.format(
			"Continue and refine our workspace code search based on this instruction:\n%s\n\n%s\n%s",
			user_input,
			visual_context,
			streaming_rules
		)
	else
		context_prompt = string.format(
			"Search the entire workspace for code matching this concept, pattern, or code shape:\n%s\n\n%s\n%s",
			user_input,
			visual_context,
			streaming_rules
		)
	end

	local cmd = {
		"agy",
		"--model=gemini-3.8-flash",
		"--effort=low",
		"--output-format=stream-json",
	}

	if continue_last and M.last_search and M.last_search.conversation_id then
		table.insert(cmd, "--conversation")
		table.insert(cmd, M.last_search.conversation_id)
	end

	table.insert(cmd, "-p")
	table.insert(cmd, context_prompt)

	local fidget_ok, fidget_progress = pcall(require, "fidget.progress")
	local progress_handle
	if fidget_ok then
		progress_handle = fidget_progress.handle.create({
			title = "󰚩 agy searching workspace",
			lsp_client = { name = "agy" },
		})
	end

	local current_line = ""
	local text_stream_buffer = ""
	local active_conv_id = (continue_last and M.last_search) and M.last_search.conversation_id or nil

	local function process_model_line(line)
		line = vim.trim(line)
		if line == "" or line:match("^```") then
			return
		end

		local p_ok, json = pcall(vim.json.decode, line)
		if not (p_ok and type(json) == "table" and json.type) then
			return
		end

		if json.type == "match" then
			if json.file and json.start_line then
				table.insert(all_matches, {
					file = json.file,
					start_line = json.start_line,
					end_line = json.end_line or json.start_line,
					note = json.note or "",
				})
				local short_file = vim.fn.fnamemodify(json.file, ":~:.")
				local note_text = (json.note and json.note ~= "") and (" (" .. json.note .. ")") or ""
				add_activity_log(string.format("★ Match: %s:%d%s", short_file, json.start_line, note_text))
				current_action = "Found match in " .. short_file
				schedule_refresh()
			end
		elseif json.type == "status" then
			if json.msg and json.msg ~= "" then
				current_action = json.msg
				add_activity_log("ℹ " .. json.msg)
				if progress_handle then
					progress_handle.message = json.msg
				end
				schedule_refresh()
			end
		elseif json.type == "summary" then
			if json.text and json.text ~= "" then
				final_summary = json.text
				schedule_refresh()
			end
		end
	end

	local function handle_text_delta(delta)
		if not delta or delta == "" then
			return
		end
		text_stream_buffer = text_stream_buffer .. delta
		while true do
			local nl = text_stream_buffer:find("\n")
			if not nl then
				break
			end
			local line = text_stream_buffer:sub(1, nl - 1)
			text_stream_buffer = text_stream_buffer:sub(nl + 1)
			process_model_line(line)
		end
	end

	local function format_tool_action(tool_name, params)
		if tool_name == "view_file" then
			local p = params.AbsolutePath or params.path or ""
			return "view_file: " .. (p ~= "" and vim.fn.fnamemodify(p, ":~:.") or "file")
		elseif tool_name == "grep_search" then
			local q = (params.query or ""):gsub("[\r\n]+", " ")
			return "grep_search: '" .. q .. "'"
		elseif tool_name == "find_by_name" then
			local pat = (params.pattern or params.query or ""):gsub("[\r\n]+", " ")
			return "find_by_name: '" .. pat .. "'"
		elseif tool_name == "run_command" then
			local c = (params.CommandLine or ""):gsub("[\r\n]+", " ")
			return "run_cmd: " .. c:sub(1, 35) .. (#c > 35 and "..." or "")
		end
		return tool_name
	end

	local function process_event_line(line)
		if not line or line == "" then
			return
		end
		local p_ok, event = pcall(vim.json.decode, line)
		if not (p_ok and type(event) == "table") then
			return
		end

		if event.conversation_id then
			active_conv_id = event.conversation_id
		end

		if event.event == "step_update" and event.step_update then
			local step = event.step_update
			if step.conversation_id then
				active_conv_id = step.conversation_id
			end
			if step.step_type == "tool" then
				local tool_name = step.tool_name or (step.tool_info and step.tool_info.name) or "tool"
				local params = (step.tool_info and step.tool_info.parameters) or {}
				local desc = format_tool_action(tool_name, params)

				if step.state == "ACTIVE" then
					current_action = desc
					add_activity_log("→ " .. desc)
					if progress_handle then
						progress_handle.message = desc
					end
					schedule_refresh()
				end
			elseif step.step_type == "agent_response" and step.text_delta then
				handle_text_delta(step.text_delta)
			end
		elseif event.event == "result" and event.result then
			if event.result.conversation_id then
				active_conv_id = event.result.conversation_id
			end
		end
	end

	local job_id = vim.fn.jobstart(cmd, {
		stdout_buffered = false,
		on_stdout = function(_, data)
			if not data then
				return
			end
			data[1] = current_line .. data[1]
			current_line = data[#data]
			table.remove(data, #data)

			for _, line in ipairs(data) do
				process_event_line(line)
			end
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
			if current_line ~= "" then
				process_event_line(current_line)
				current_line = ""
			end
			if text_stream_buffer ~= "" then
				process_model_line(text_stream_buffer)
				text_stream_buffer = ""
			end

			vim.schedule(function()
				if progress_handle then
					progress_handle:finish()
					progress_handle = nil
				end

				is_searching = false
				current_action = nil
				schedule_refresh()

				M.last_search = {
					query = full_query,
					conversation_id = active_conv_id,
					mbuf = mbuf,
					summary = final_summary,
					matches = all_matches,
				}
			end)
		end
	})

	M.active_jobs[job_id] = true
end

--- Continues and refines the previous workspace search conversation.
--- @param opts? { query?: string }
function M.continue_search(opts)
	opts = opts or {}
	opts.continue_last = true
	return M.search_workspace(opts)
end

M.prompt_search = M.search_workspace

return M
