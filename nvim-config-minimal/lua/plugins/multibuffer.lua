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

			-- do_fzf("rg --column", {
			-- 	fzf_args = {
			-- 		"--preview", "bat --style=numbers --color=always --highlight-line {2} {1}",
			-- 		"--preview-window", "~4,+{2}+4/3,up:75%",
			-- 		"--bind", "change:reload:rg --column {q}",
			-- 		"--bind", "enter:become(echo {\"filename\": {+1}, \"line\": {+2}, \"col\": {+3}})",
			-- 		"--delimiter", ":",
			-- 	},
			-- }),
			vim.keymap.set({ "n", "v" }, "<C-w>/", function()
				local word = vim.fn.expand("<cword>")
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
						last_proc:close(function() end)
						last_proc = nil
					end

					local new_proc_stdin, new_proc_stdin_err = vim.uv.new_pipe(false)
					assert(new_proc_stdin, new_proc_stdin_err)
					-- last_proc_stdin = new_proc_stdin

					local new_proc_stdout, new_proc_stdout_err = vim.uv.new_pipe(false)
					assert(new_proc_stdout, new_proc_stdout_err)
					last_proc_stdout = new_proc_stdout

					local new_proc_stderr, new_proc_stderr_err = vim.uv.new_pipe(false)
					assert(new_proc_stderr, new_proc_stderr_err)
					last_proc_stderr = new_proc_stderr

					local new_proc, new_proc_err = vim.uv.spawn("rg", {
						stdio = { new_proc_stdin, new_proc_stdout, new_proc_stderr },
						hide = true,
						cwd = vim.uv.cwd(),
						args = {
							"--json",
							-- "--vimgrep",
							query,
						},
					}, function(code, signal)
						vim.schedule(function()
							vim.notify("rg exited: " .. vim.inspect({ code = code, signal = signal }))
						end)
					end)
					assert(new_proc, new_proc_err)

					--- @type table<string, MultibufRegion[]>
					local regions_by_filename = {}

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
						if err or not data then
							if err then
								vim.schedule(function()
									vim.notify(vim.inspect(err), vim.log.levels.ERROR)
								end)
							end
							return
						end

						local lines = vim.split(data, "\n", { trimempty = true, plain = true })
						if #lines == 0 then
							return
						end

						-- lines[1] = stdout_leftovers .. lines[1]
						-- stdout_leftovers = ""

						for _, line in ipairs(lines) do
							local success, msg = pcall(vim.json.decode, line, {})

							if not success then
								vim.schedule(function()
									vim.notify("json decode fail: " .. vim.inspect(msg), vim.log.levels.ERROR)
								end)
								return
							end

							if msg.type == "begin" then
								local path = msg.data.path.text
								regions_by_filename[path] = {}
							elseif msg.type == "end" then
								local path = msg.data.path.text
								vim.schedule(function()
									local path_bufnr = vim.fn.bufadd(path)
									vim.fn.bufload(path_bufnr)
									multibuffer.multibuf_add_buf(search_mbuf, {
										buf = path_bufnr,
										regions = regions_by_filename[path],
									})
								end)
							elseif msg.type == "match" then
								local path = msg.data.path.text
								local match_lnum = msg.data.line_number
								--- @type MultibufRegion
								local region = { start_row = match_lnum + 1, end_row = match_lnum + 1 }
								assert(regions_by_filename[path])
								vim.notify(vim.inspect(region))
								table.insert(regions_by_filename[path], region)
							else
							end

							vim.schedule(function()
								vim.notify(vim.inspect(msg.type))
							end)
						end
					end)

					vim.uv.write(new_proc_stdin, "\r\n")
					vim.uv.shutdown(new_proc_stdin, function() end)
				end

				local input = ""

				local function input_changed()
					vim.schedule(function()
						spawn_proc(input)
					end)
				end

				local function submit() end

				local function update_input()
					vim.api.nvim_set_option_value("modified", false, { buf = prompt_bufnr })
					local new_input = vim.api.nvim_buf_get_lines(prompt_bufnr, 0, -1, true)[1]
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
			end, { desc = "open search window" })
		end,
	},
}
