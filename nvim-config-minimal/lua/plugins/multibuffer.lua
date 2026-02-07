local multibuffer_expand = 1

local function render_multibuf_title(bufnr)
	local icons = require("nvim-web-devicons")
	local buf_name = vim.api.nvim_buf_get_name(bufnr)
	local icon, icon_hl_group = icons.get_icon(buf_name)
	local nice_buf_name = vim.fn.fnamemodify(buf_name, ":~:.")
	nice_buf_name = string.gsub(nice_buf_name, "\\", "/")

	icon = icon or ""
	icon_hl_group = icon_hl_group or "DevIconDefault"

	local title = { { " " }, { icon, icon_hl_group }, { " ", "" }, { nice_buf_name, "MultibufferTitleName" }, { " " } }
	local title_text_length = 0
	for _, part in ipairs(title) do
		title_text_length = title_text_length + string.len(part[1])
	end

	local top_text = "╭" .. string.rep("─", title_text_length - 2) .. "╮"
	local bottom_text = "╰" .. string.rep("─", title_text_length - 2) .. "╯"

	table.insert(title, 1, { "│", "MultibufferTitleBorder" })
	table.insert(title, { "│", "MultibufferTitleBorder" })

	return {
		{ { top_text, "MultibufferTitleBorder" } },
		title,
		{ { bottom_text, "MultibufferTitleBorder" } },
	}
end

return {
	{
		"zaucy/multibuffer.nvim",
		dir = "~/projects/zaucy/multibuffer.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			local multibuffer = require("multibuffer")
			multibuffer.setup({
				render_multibuf_title = render_multibuf_title,
			})

			vim.api.nvim_set_hl(0, "MultibufferTitleBorder", { link = "FloatBorder" })
			vim.api.nvim_set_hl(0, "MultibufferTitleName", { link = "FloatTitle" })

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "multibuffer",
				callback = function(args)
					vim.keymap.set("n", "<cr>", function()
						local cursor = vim.api.nvim_win_get_cursor(0)
						local buf, line = multibuffer.multibuf_get_buf_at_line(args.buf, cursor[1])
						if buf then
							vim.api.nvim_set_current_buf(buf)
							vim.api.nvim_win_set_cursor(0, { line, cursor[2] })
						end
					end, { buffer = args.buf, desc = "Jump to source" })
				end,
			})

			vim.api.nvim_create_autocmd("BufWinEnter", {
				pattern = "multibuffer://*",
				callback = function(args)
					local winid = vim.api.nvim_get_current_win()
					vim.api.nvim_set_option_value("number", false, { scope = "local", win = winid })
					vim.api.nvim_set_option_value("relativenumber", false, { scope = "local", win = winid })
					vim.api.nvim_set_option_value("signcolumn", "yes:3", { scope = "local", win = winid })
				end,
			})

			vim.keymap.set({ "n", "v" }, "<C-w>/", function()
				local cword = vim.fn.expand("<cword>")
				local mbuf = require("multibuffer")

				local search_mbuf = mbuf.create_multibuf()
				local win = vim.api.nvim_get_current_win()
				local win_opts = vim.api.nvim_win_get_config(win)
				vim.api.nvim_win_set_buf(win, search_mbuf)

				mbuf.multibuf_set_header(search_mbuf, { "", "", "" })

				local prompt_bufnr = vim.api.nvim_create_buf(false, false)
				vim.bo[prompt_bufnr].buftype = "prompt"
				vim.fn.prompt_setprompt(prompt_bufnr, " ")

				local prompt_win = nil

				local ensure_prompt_win = function()
					if prompt_win and vim.api.nvim_win_is_valid(prompt_win) then
						return
					end

					prompt_win = vim.api.nvim_open_win(prompt_bufnr, true, {
						relative = "win",
						anchor = "SW",
						row = 3,
						col = 0,
						height = 1,
						width = win_opts.width - 2,
						border = "solid",
						win = win,
					})

					vim.wo[prompt_win].winfixbuf = true
					vim.wo[prompt_win].signcolumn = "no"
					vim.wo[prompt_win].number = false
					vim.wo[prompt_win].relativenumber = false
				end

				ensure_prompt_win()
				assert(prompt_win)

				--- @type uv.uv_process_t|nil
				local last_proc = nil
				--- @type uv.uv_pipe_t|nil
				local last_proc_stdout = nil
				--- @type uv.uv_pipe_t|nil
				local last_proc_stderr = nil

				--- @param query string
				local function spawn_proc(query)
					if last_proc_stderr and not last_proc_stderr:is_closing() then
						last_proc_stderr:close(function() end)
						last_proc_stderr = nil
					end
					if last_proc_stdout and not last_proc_stdout:is_closing() then
						last_proc_stdout:close(function() end)
						last_proc_stdout = nil
					end
					if last_proc and not last_proc:is_closing() then
						-- last_proc:close(function() end)
						last_proc:kill("sigint")
						last_proc = nil
					end

					if not query then
						return
					end

					local new_proc_stdout, new_proc_stdout_err = vim.uv.new_pipe(false)
					assert(new_proc_stdout, new_proc_stdout_err)
					last_proc_stdout = new_proc_stdout

					local new_proc_stderr, new_proc_stderr_err = vim.uv.new_pipe(false)
					assert(new_proc_stderr, new_proc_stderr_err)
					last_proc_stderr = new_proc_stderr

					local spawn_args = {
						"--json",
						-- "--vimgrep",
						query,
					}

					local new_proc, new_proc_err = vim.uv.spawn("rg", {
						stdio = { nil, new_proc_stdout, new_proc_stderr },
						hide = true,
						cwd = vim.uv.cwd(),
						verbatim = false,
						args = spawn_args,
					}, function(code, signal)
						if code ~= 0 then
							vim.schedule(function()
								vim.notify(
									"rg exited: " .. vim.inspect({ code = code, signal = signal }),
									vim.log.levels.ERROR
								)
							end)
						end
					end)
					assert(new_proc, new_proc_err)

					--- @type table<string, MultibufRegion[]>
					local regions_by_filename = {}
					--- @type string[]
					local done_searching_paths = {}
					local done_schedule_active = false
					local total_searched_paths = 0
					local stats = nil

					local process_done_searching_paths = vim.schedule_wrap(function()
						local add_opts = {}

						for _, path in ipairs(done_searching_paths) do
							local path_bufnr = vim.fn.bufadd(path)
							local regions = regions_by_filename[path]

							table.sort(regions, function(a, b)
								return a.start_row < b.start_row
							end)

							local merged_regions = {}
							for _, region in ipairs(regions) do
								if #merged_regions == 0 then
									table.insert(merged_regions, region)
								else
									local last = merged_regions[#merged_regions]
									if region.start_row <= last.end_row then
										last.end_row = math.max(last.end_row, region.end_row)
									else
										table.insert(merged_regions, region)
									end
								end
							end

							table.insert(add_opts, {
								buf = path_bufnr,
								regions = merged_regions,
							})
						end

						total_searched_paths = total_searched_paths + #done_searching_paths
						-- vim.fn.prompt_setprompt(prompt_bufnr, "[" .. total_searched_paths .. "]  ")

						multibuffer.multibuf_add_bufs(search_mbuf, add_opts)

						done_searching_paths = {}
						done_schedule_active = false

						-- stats: {
						--   bytes_printed = 26203636,
						--   bytes_searched = 6602263,
						--   elapsed = {
						--     human = "0.109379s",
						--     nanos = 109378500,
						--     secs = 0
						--   },
						--   matched_lines = 77874,
						--   matches = 157317,
						--   searches = 2121,
						--   searches_with_match = 1556
						-- }

						-- vim.notify("stats: " .. vim.inspect(stats))
					end)

					local try_schedule_done_searching_paths = function()
						if done_schedule_active then
							return
						end
						done_schedule_active = true
						process_done_searching_paths()
					end

					vim.uv.read_start(new_proc_stderr, function(err, data)
						if err or not data then
							return
						end

						vim.schedule(function()
							vim.notify(data, vim.log.levels.ERROR)
						end)
					end)

					local stdout_leftovers = ""
					vim.uv.read_start(new_proc_stdout, function(err, data)
						-- should have been closed, but ignore just incase
						if last_proc_stdout ~= new_proc_stdout then
							return
						end

						if err or not data then
							if err then
								vim.schedule(function()
									vim.notify(err, vim.log.levels.ERROR)
								end)
							end
							return
						end

						local lines = vim.split(stdout_leftovers .. data, "\n", { plain = true })
						stdout_leftovers = table.remove(lines)

						for _, line in ipairs(lines) do
							if line ~= "" then
								local success, msg = pcall(vim.json.decode, line)

								if not success then
									vim.schedule(function()
										vim.notify("json decode fail: " .. vim.inspect(msg), vim.log.levels.ERROR)
									end)
									return
								end

								if msg.data.stats then
									stats = msg.data.stats
								end

								if msg.type == "begin" then
									local path = msg.data.path.text
									regions_by_filename[path] = {}
								elseif msg.type == "end" then
									local path = msg.data.path.text
									table.insert(done_searching_paths, path)
									try_schedule_done_searching_paths()
								elseif msg.type == "match" then
									local path = msg.data.path.text
									local match_lnum = msg.data.line_number
									--- @type MultibufRegion
									local region = {
										start_row = match_lnum - 1 - multibuffer_expand,
										end_row = match_lnum - 1 + multibuffer_expand,
									}
									assert(regions_by_filename[path])
									table.insert(regions_by_filename[path], region)
								end
							end
						end
					end)
				end

				local input = ""

				local input_changed = vim.schedule_wrap(function()
					multibuffer.multibuf_clear_bufs(search_mbuf)
					spawn_proc(input)
				end)

				local function submit() end

				local update_input = function()
					vim.api.nvim_set_option_value("modified", false, { buf = prompt_bufnr })
					local new_input = vim.trim(vim.fn.prompt_getinput(prompt_bufnr))
					if new_input ~= input then
						input = new_input
						input_changed()
					end
				end

				vim.fn.prompt_setcallback(prompt_bufnr, function()
					update_input()
					submit()
				end)

				vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI", "TextChangedP" }, {
					buffer = prompt_bufnr,
					callback = function()
						update_input()
					end,
				})

				local move_to_mbuf = function(key)
					return function()
						vim.api.nvim_set_current_win(win)
						local line_count = vim.api.nvim_buf_line_count(search_mbuf)
						local cursor = vim.api.nvim_win_get_cursor(win)
						if cursor[1] <= 3 then
							vim.api.nvim_win_set_cursor(win, { math.min(4, line_count), 0 })
						end
						if key then
							vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, false, true), "n", true)
						end
					end
				end

				local motion_keys = {
					"j",
					"k",
					"<Down>",
					"<Up>",
					"<C-d>",
					"<C-u>",
					"<C-f>",
					"<C-b>",
					"<PageDown>",
					"<PageUp>",
					"G",
					"gg",
				}

				for _, key in ipairs(motion_keys) do
					-- only map printable keys in normal mode to avoid blocking typing in insert mode
					local modes = (string.len(key) > 1 or key:match("%W")) and { "n", "i" } or { "n" }
					vim.keymap.set(modes, key, move_to_mbuf(key), { buffer = prompt_bufnr })
				end

				vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
					buffer = search_mbuf,
					callback = function()
						if vim.api.nvim_get_current_win() ~= win then
							return
						end
						local cursor = vim.api.nvim_win_get_cursor(win)
						if cursor[1] <= 3 then
							ensure_prompt_win()
							vim.api.nvim_set_current_win(prompt_win)
							vim.cmd("startinsert")
						end
					end,
				})

				vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
					callback = function()
						local current_win = vim.api.nvim_get_current_win()
						if current_win == prompt_win then
							return
						end

						local current_win_buf = vim.api.nvim_win_get_buf(current_win)
						if current_win_buf == search_mbuf then
							ensure_prompt_win()
							win = current_win
							win_opts = vim.api.nvim_win_get_config(win)
							vim.api.nvim_win_set_width(prompt_win, win_opts.width - 2)

							local prompt_win_options = vim.api.nvim_win_get_config(prompt_win)
							prompt_win_options.win = win
							prompt_win_options.hide = false
							vim.api.nvim_win_set_config(prompt_win, prompt_win_options)
						elseif current_win == win then
							local prompt_win_options = vim.api.nvim_win_get_config(prompt_win)
							prompt_win_options.hide = true
							vim.api.nvim_win_set_config(prompt_win, prompt_win_options)
						end
					end,
				})

				vim.api.nvim_create_autocmd({ "WinClosed" }, {
					buffer = search_mbuf,
					callback = function(args)
						assert(args.buf == search_mbuf)
						local prompt_win_options = vim.api.nvim_win_get_config(prompt_win)
						prompt_win_options.hide = true
						vim.api.nvim_win_set_config(prompt_win, prompt_win_options)
					end,
				})

				vim.api.nvim_create_autocmd({ "WinResized" }, {
					callback = function(args)
						if args.buf ~= search_mbuf then
							return
						end

						win = vim.api.nvim_get_current_win()

						ensure_prompt_win()
						assert(prompt_win)

						win_opts = vim.api.nvim_win_get_config(win)
						vim.api.nvim_win_set_width(prompt_win, win_opts.width - 2)
					end,
				})

				vim.cmd("startinsert")
				if cword ~= "" then
					vim.api.nvim_feedkeys(cword, "n", true)
					vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<esc>vT <C-g>", true, false, true), "n", true)
				end
			end, { desc = "open search window" })
		end,
	},
}
