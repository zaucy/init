local ns_id = vim.api.nvim_create_namespace('ZaucySubstituteNS')

vim.cmd("highlight ZaucySubstituteSelect guibg=#151521")

local setcmdline_delayed = vim.schedule_wrap(function (cmdline, pos)
	vim.fn.setcmdline(cmdline, pos)
	-- TODO: somehow trigger an update on the cmdline
end)

local function start_cmdline_with_temp_cr(opts)
	local original_mapping = vim.fn.maparg('<CR>', 'c', false, true)
	local cleanup_group = vim.api.nvim_create_augroup('TempCmdlineMapping', { clear = true })
	vim.api.nvim_create_autocmd('CmdlineLeave', {
		group = cleanup_group,
		callback = function()
			---@diagnostic disable-next-line: param-type-mismatch
			if not vim.tbl_isempty(original_mapping) then
				vim.keymap.set('c', '<CR>', original_mapping.rhs, {
					silent = original_mapping.silent == 1,
					expr = original_mapping.expr == 1,
					noremap = original_mapping.noremap == 1,
				})
			else
				vim.keymap.del('c', '<CR>')
			end
			vim.api.nvim_del_augroup_by_name('TempCmdlineMapping')
			if opts.cleanup then
				return opts.cleanup()
			end
		end,
		once = true,
	})

	vim.keymap.set('c', '<CR>', function()
		if opts.cr_handler then
			return opts.cr_handler()
		end
		return '<CR>'
	end, { expr = true, replace_keycodes = true })

	vim.fn.feedkeys(":")

	setcmdline_delayed(opts.initial_cmdline, opts.initial_cmdline_pos)
end

local function generate_range_pattern(start_pos, end_pos)
	local start_row = start_pos[1]
	local start_col = start_pos[2] + 1
	local end_row = end_pos[1]
	local end_col = end_pos[2] + 1
	local range = string.format("%d,%d", start_row, end_row)
	local col_pattern
	if start_row == end_row then
		col_pattern = string.format(
			"\\%%%dl\\%%>%dc\\%%<%dc",
			start_row,
			start_col - 1,  -- -1 to make it inclusive
			end_col + 1     -- +1 to make it inclusive
		)
	else
		col_pattern = string.format(
			"\\(\\%%%dl\\%%>%dc\\|\\%%%dl\\%%<%dc%s\\)",
			start_row,
			start_col - 1,
			end_row,
			end_col + 1,
			start_row + 1 < end_row and string.format("\\|\\%%>%dl\\%%<%dl", start_row, end_row) or ""
		)
	end
	return {
		range = range,
		col_pattern = col_pattern,
		full_pattern = range .. "s/" .. col_pattern
	}
end

---@diagnostic disable-next-line: unused-local
function _G.zaucy_subst_op(motion_type)
	local start_pos = vim.api.nvim_buf_get_mark(0, '[')
	local end_pos = vim.api.nvim_buf_get_mark(0, ']')
	local lines = vim.api.nvim_buf_get_text(
		0,
		start_pos[1] - 1,
		start_pos[2],
		end_pos[1] - 1,
		end_pos[2] + 1,
		{}
	)

	if #lines > 1 then
		local r = generate_range_pattern(start_pos, end_pos)
		local cmdline = r.full_pattern .. "\\V"
		local highlight_id = vim.api.nvim_buf_set_extmark(0, ns_id, start_pos[1] - 1, start_pos[2], {
			end_line = end_pos[1] - 1,
			end_col = end_pos[2],
			hl_group = "ZaucySubstituteSelect"
		})
		start_cmdline_with_temp_cr({
			initial_cmdline = cmdline,
			initial_cmdline_pos = #cmdline + 1,
			cr_handler = function()
				cmdline = vim.fn.getcmdline()
				if vim.endswith(cmdline, "/g") then
					return "<cr>"
				else
					cmdline = cmdline .. "//g"
					vim.fn.setcmdline(cmdline, #cmdline - 1)
					return ""
				end
			end,
			cleanup = function()
				vim.api.nvim_buf_del_extmark(0, ns_id, highlight_id)
			end
		})
	else
		local content = table.concat(lines, "\n"):gsub("/", "\\/")
		local cmdline = "%s/\\V" .. content .. "/" .. content .. "/g"
		vim.fn.feedkeys(":")
		setcmdline_delayed(cmdline, #cmdline - 1)
	end
end

---@diagnostic disable-next-line: unused-local
function _G.zaucy_subst_delete_op(motion_type)
	local start_pos = vim.api.nvim_buf_get_mark(0, '[')
	local end_pos = vim.api.nvim_buf_get_mark(0, ']')
	local lines = vim.api.nvim_buf_get_text(
		0,
		start_pos[1] - 1,
		start_pos[2],
		end_pos[1] - 1,
		end_pos[2] + 1,
		{}
	)
	if #lines > 1 then
		vim.notify("Cannot subsitute delete multiple lines", vim.log.levels.ERROR)
	else
		local content = table.concat(lines, "\n"):gsub("/", "\\/")
		local cmdline = "%s/\\V" .. content .. "/" .. "/g"
		vim.fn.feedkeys(":")
		setcmdline_delayed(cmdline, #cmdline - 1)
	end
end

vim.keymap.set({ 'n', 'v' }, 's', function()
	vim.opt.operatorfunc = 'v:lua.zaucy_subst_op'
	return 'g@'
end, { expr = true })

vim.keymap.set({ 'n' }, 'sd', function()
	vim.opt.operatorfunc = 'v:lua.zaucy_subst_delete_op'
	return 'g@'
end, { expr = true })

vim.keymap.set({ "v" }, '/', '<esc>/\\%V') -- search in selection

local function goto_closest_file(filename)
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

vim.keymap.set({ "n" }, "gbb", goto_closest_file("BUILD.bazel"), { desc = "Bazel Build File" })
vim.keymap.set({ "n" }, "gbm", goto_closest_file("MODULE.bazel"), { desc = "Bazel Module File" })
vim.keymap.set({ "n" }, "gbw", goto_closest_file("WORKSPACE.bazel"), { desc = "Bazel Workspace File" })
vim.keymap.set({ "n" }, "gbz", goto_closest_file(".bazelrc"), { desc = "Bazelrc File" })

vim.keymap.set({ "n", "v" }, "<leader>qd", "<cmd>BazelDebug<cr>",
	{ desc = "Build and launch bazel target with nvim-dap" })

for i = 1, 9 do
	vim.keymap.set({ "n", "v", "t" }, "<C-" ..tostring(i) .. ">", function() require('zaucy.tabline').goto(i) end, { desc = "Goto tab " .. tostring(i) })
end

local term_buf_closed = {}

vim.api.nvim_create_autocmd("TermClose", {
	callback = function(event)
		term_buf_closed[event.buf] = true
	end
})

local function is_bufvalid(buf)
	if buf == nil then return false end
	if not vim.api.nvim_buf_is_valid(buf) then return false end
	local buftype = vim.bo[buf].buftype

	if buftype == "terminal" then
		return not term_buf_closed[buf]
	end

	if buftype == "prompt" then return false end
	if buftype == "nofile" then return false end
	return true
end

local function find_nearby_valid_buf(bufs, start_index)
	local offset = 1
	while true do
		if start_index + offset > #bufs and start_index - offset < 0 then
			return nil
		end

		if is_bufvalid(bufs[start_index + offset]) then
			return bufs[start_index + offset]
		elseif is_bufvalid(bufs[start_index - offset]) then
			return bufs[start_index - offset]
		end

		offset = offset + 1
	end
end

local function is_buf_similar(buf1, buf2)
	if vim.bo[buf1].buftype ~= vim.bo[buf2].buftype then
		return false
	end

	if vim.bo[buf1].filetype ~= vim.bo[buf2].filetype then
		return false
	end

	return true
end

local function wrap_access(list, index)
	-- zero-base this nerd
	index = index - 1
	local wrapped_index = index % #list
	return list[wrapped_index + 1]
end

local function find_similar_buf(bufs, start_index, offset)
	assert(start_index ~= nil, "start_index must be set")
	assert(start_index > 0, "start_index must be greater than 0")
	assert(start_index <= #bufs, "start_index must be within bufs range")
	if #bufs < 2 then
		return nil
	end

	local curbuf = vim.api.nvim_get_current_buf()

	offset = offset or 1
	for i = 0, #bufs - 1 do
		local buf = wrap_access(bufs, start_index + i + offset)
		if buf ~= curbuf and is_bufvalid(buf) then
			if is_buf_similar(0, buf) then
				return buf
			end
		end
	end

	return nil
end

local function get_buf_index(buf, bufs)
	if buf == 0 then
		buf = vim.api.nvim_get_current_buf()
	end

	assert(buf ~= nil)

	if bufs == nil then
		bufs = vim.api.nvim_list_bufs()
	end

	for i, _ in ipairs(bufs) do
		if bufs[i] == buf then
			return i
		end
	end

	return nil
end

local function goto_next_similar_buffer()
	local bufs = vim.api.nvim_list_bufs()
	local curr_index = get_buf_index(0, bufs)
	local buf = find_similar_buf(bufs, curr_index, 1)
	if buf == nil then
		vim.notify(
			"No other similar buffers (buftype=" .. vim.bo.buftype .. ", filetype=" .. vim.bo.filetype .. ")",
			vim.log.levels.WARN
		)
		return
	end
	vim.api.nvim_set_current_buf(buf)
end

local function goto_prev_similar_buffer()
	local bufs = vim.api.nvim_list_bufs()
	local curr_index = get_buf_index(0, bufs)
	local buf = find_similar_buf(bufs, curr_index, -1)
	if buf == nil then
		vim.notify(
			"No other similar buffers (buftype=" .. vim.bo.buftype .. ", filetype=" .. vim.bo.filetype .. ")",
			vim.log.levels.WARN
		)
		return
	end
	vim.api.nvim_set_current_buf(buf)
end

local last_buf_before_terminal = {}
local last_term_buf = {}

vim.api.nvim_create_autocmd({ 'BufWinEnter', 'BufEnter' }, {
	callback = function()
		if vim.bo.buftype == "terminal" then
			last_term_buf[vim.api.nvim_get_current_tabpage()] = vim.api.nvim_get_current_buf()
		end
	end,
})


vim.api.nvim_create_autocmd({ 'TermOpen' }, {
	callback = function()
		if vim.bo.buftype == "terminal" then
			last_term_buf[vim.api.nvim_get_current_tabpage()] = vim.api.nvim_get_current_buf()
		end
	end,
})


local function close_terminal()
	if vim.bo.buftype ~= "terminal" then
		return
	end

	local win = vim.api.nvim_get_current_win()
	local currbuf = vim.fn.winbufnr(win)

	if is_bufvalid(last_buf_before_terminal[win]) then
		vim.api.nvim_set_current_buf(last_buf_before_terminal[win])
		return
	end

	last_buf_before_terminal[win] = nil

	local allbufs = vim.api.nvim_list_bufs()
	for i, buf in ipairs(allbufs) do
		if buf == currbuf then
			local nearby_buf = find_nearby_valid_buf(allbufs, i)
			if nearby_buf ~= nil then
				vim.api.nvim_set_current_buf(nearby_buf)
			else
				vim.cmd("enew")
			end
			return
		end
	end

	vim.cmd("enew")
end

local function open_terminal()
	if vim.bo.buftype == "terminal" then
		close_terminal()
		return
	end

	last_buf_before_terminal[vim.api.nvim_get_current_win()] = vim.api.nvim_get_current_buf()

	local tabpage = vim.api.nvim_get_current_tabpage()

	if is_bufvalid(last_term_buf[tabpage]) then
		---@diagnostic disable-next-line: param-type-mismatch
		vim.api.nvim_set_current_buf(last_term_buf[tabpage])
		return
	end

	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.bo[buf].buftype == "terminal" and is_bufvalid(buf) then
			vim.api.nvim_set_current_buf(buf)
			last_term_buf[tabpage] = buf
			return
		end
	end

	vim.cmd("terminal nu")
end

local function sigint_terminal()
	if vim.bo.buftype ~= "terminal" then
		return
	end

	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-c>', true, false, true), 'n', true)
	vim.api.nvim_command('startinsert')
end

vim.keymap.set({ "n" }, "<C-_>", open_terminal, { desc = "Open Terminal" })
vim.keymap.set({ "n" }, "<C-/>", open_terminal, { desc = "Open Terminal" })
vim.keymap.set({ "t" }, "<C-w>", "<C-\\><C-n><cmd>WhichKey <C-w><cr>", {})
vim.keymap.set({ "t" }, "<C-/>", close_terminal, { desc = "Hide Terminal" })
vim.keymap.set({ "t" }, "<C-_>", close_terminal, { desc = "Hide Terminal" })
vim.keymap.set({ "n", "v" }, "<C-c>", sigint_terminal, { desc = "Ctrl-C terminal", noremap = true, silent = true })
vim.keymap.set({ "t" }, "<S-Insert>", "<C-\\><C-n>\"+pi", { desc = "Paste In Terminal" })

vim.keymap.set({ "n" }, "]]", goto_next_similar_buffer, { desc = "Next Similar Buf" })
vim.keymap.set({ "n" }, "[[", goto_prev_similar_buffer, { desc = "Next Similar Buf" })

-- move lines
vim.keymap.set({ "n" }, "<a-j>", "<cmd>m .+1<cr>==", { desc = "move down" })
vim.keymap.set({ "n" }, "<a-k>", "<cmd>m .-2<cr>==", { desc = "move up" })
vim.keymap.set({ "i" }, "<a-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "move down" })
vim.keymap.set({ "i" }, "<a-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "move up" })
vim.keymap.set({ "v" }, "<a-j>", ":m '>+1<cr>gv=gv", { desc = "move down" })
vim.keymap.set({ "v" }, "<a-k>", ":m '<-2<cr>gv=gv", { desc = "move up" })

vim.keymap.set({ "n" }, "<a-down>", "<cmd>m .+1<cr>==", { desc = "move down" })
vim.keymap.set({ "n" }, "<a-up>", "<cmd>m .-2<cr>==", { desc = "move up" })
vim.keymap.set({ "i" }, "<a-down>", "<esc><cmd>m .+1<cr>==gi", { desc = "move down" })
vim.keymap.set({ "i" }, "<a-up>", "<esc><cmd>m .-2<cr>==gi", { desc = "move up" })
vim.keymap.set({ "v" }, "<a-down>", ":m '>+1<cr>gv=gv", { desc = "move down" })
vim.keymap.set({ "v" }, "<a-up>", ":m '<-2<cr>gv=gv", { desc = "move up" })

-- buffers
vim.keymap.set({ "n" }, "[b", "<cmd>bprevious<cr>", { desc = "prev buffer" })
vim.keymap.set({ "n" }, "]b", "<cmd>bnext<cr>", { desc = "next buffer" })

-- lsp
vim.keymap.set({ "n" }, "gd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Goto Definition" })
vim.keymap.set({ "n" }, "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
vim.keymap.set({ "n" }, "gi", vim.lsp.buf.implementation, { desc = "Goto Implementation" })
vim.keymap.set({ "n" }, "gri", vim.lsp.buf.incoming_calls, { desc = "vim.lsp.buf.incoming_calls()" })
vim.keymap.set({ "n" }, "gro", vim.lsp.buf.outgoing_calls, { desc = "vim.lsp.buf.outgoing_calls()" })
vim.keymap.set({ "n" }, "grr", "<cmd>Telescope lsp_references<cr>", { desc = "vim.lsp.buf.outgoing_calls()" })
vim.keymap.set({ "n" }, "grn", ":IncRename ", { desc = "rename" })
vim.keymap.set(
	{ "n", "v" },
	"<leader>S",
	function() require('zaucy.lsp').dynamic_workspace_symbols({ theme = "ivy" }) end,
	{ desc = "Workspace symbols" }
)


-- quickfix
vim.keymap.set({ "n" }, "[q", "<cmd>cprevious<cr>", { desc = "prev qf item" })
vim.keymap.set({ "n" }, "]q", "<cmd>cnext<cr>", { desc = "next qf item" })

-- some script runners
vim.keymap.set({ "n", "v" }, "<C-S-B>", function() end, { desc = "" })
