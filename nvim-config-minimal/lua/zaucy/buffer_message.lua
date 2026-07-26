local M = {}

_G._agy_statuscolumn = function()
	local row = vim.v.lnum - 1
	local virtnum = vim.v.virtnum

	if virtnum > 0 then
		local connector_ns = vim.api.nvim_create_namespace("agy_connectors")
		local marks = vim.api.nvim_buf_get_extmarks(0, connector_ns, { row, 0 }, { row, 0 }, { limit = 1 })
		if #marks > 0 then
			return "%#Comment#│%* %="
		end
		return "%C%s%="
	elseif virtnum < 0 then
		return "%C%s%="
	end

	return "%C%s%=%{v:relnum?v:relnum:v:lnum} "
end

local active_messages = {}

local Message = {}
Message.__index = Message

function Message.new(opts)
	local self = setmetatable({
		opts = vim.deepcopy(opts),
		is_visible = false,
		id = nil,
		bottom_id = nil,
		sign_ids = {},
	}, Message)
	table.insert(active_messages, self)
	return self
end

function Message:update(new_opts)
	for k, v in pairs(new_opts) do
		self.opts[k] = v
	end
	if self.is_visible then
		self:hide()
		self:show()
	end
end

function Message:hide()
	if not self.is_visible then
		return
	end
	self.is_visible = false
	pcall(vim.api.nvim_buf_del_extmark, self.opts.bufnr, self.opts.ns, self.id)
	if self.bottom_id then
		pcall(vim.api.nvim_buf_del_extmark, self.opts.bufnr, self.opts.ns, self.bottom_id)
	end
	for _, sid in ipairs(self.sign_ids) do
		pcall(vim.api.nvim_buf_del_extmark, self.opts.bufnr, self.opts.connector_ns, sid)
	end
	self.id = nil
	self.bottom_id = nil
	self.sign_ids = {}
end

function Message:destroy()
	self:hide()
	for i, m in ipairs(active_messages) do
		if m == self then
			table.remove(active_messages, i)
			break
		end
	end
end

function M.clear(bufnr)
	for i = #active_messages, 1, -1 do
		local msg = active_messages[i]
		if not bufnr or msg.opts.bufnr == bufnr then
			msg:destroy()
		end
	end
end

vim.api.nvim_create_autocmd({ "VimResized", "OptionSet" }, {
	pattern = { "*", "wrap" },
	callback = function()
		if _G._buffer_message_timer then
			_G._buffer_message_timer:stop()
		end
		_G._buffer_message_timer = vim.defer_fn(function()
			M.redraw_all()
		end, 100)
	end,
})

function M.redraw_all()
	local current = vim.deepcopy(active_messages)
	for _, msg in ipairs(current) do
		if msg.is_visible and vim.api.nvim_buf_is_valid(msg.opts.bufnr) then
			local ok, pos = pcall(vim.api.nvim_buf_get_extmark_by_id, msg.opts.bufnr, msg.opts.ns, msg.id, {})
			if ok and #pos > 0 then
				msg.opts.line = pos[1] + 1
				if msg.opts.end_line and msg.bottom_id then
					local b_ok, b_pos =
						pcall(vim.api.nvim_buf_get_extmark_by_id, msg.opts.bufnr, msg.opts.ns,
							msg.bottom_id, {})
					if b_ok and #b_pos > 0 then
						msg.opts.end_line = b_pos[1]
					end
				end
				msg:hide()
				msg:show()
			end
		end
	end
end

local function wrap_text(text, max_width)
	local lines = {}
	for line in text:gmatch("([^\n]*)\n?") do
		if line == "" then
			table.insert(lines, "")
		else
			while #line > max_width do
				local space_idx = line:sub(1, max_width):match(".*%s()")
				if space_idx and space_idx > 1 then
					table.insert(lines, line:sub(1, space_idx - 1))
					line = line:sub(space_idx)
				else
					table.insert(lines, line:sub(1, max_width))
					line = line:sub(max_width + 1)
				end
			end
			table.insert(lines, line)
		end
	end
	if #lines == 0 then
		table.insert(lines, "")
	end
	return lines
end

function Message:show()
	if self.is_visible then
		return
	end
	if not vim.api.nvim_buf_is_valid(self.opts.bufnr) then
		return
	end

	local opts = self.opts
	local bufnr = opts.bufnr
	local ns = opts.ns
	local connector_ns = opts.connector_ns
	local line = opts.line
	local msg = opts.msg
	local end_line = opts.end_line
	local tail_msg = opts.tail_msg
	local hl = opts.hl_group or "Comment"

	local win_width = vim.api.nvim_win_get_width(0)
	local textoff = 0
	local wininfo = vim.fn.getwininfo(vim.api.nvim_get_current_win())
	if wininfo and wininfo[1] then
		textoff = wininfo[1].textoff
	end

	local wrap_width = 80
	if vim.wo.wrap then
		-- Use window width minus textoff and some padding for the border
		wrap_width = math.max(40, win_width - textoff - 4)
	end

	local msg_lines = wrap_text(msg, wrap_width)
	local tail_lines = end_line and wrap_text(tail_msg or "", wrap_width) or {}

	local max_len = 0
	for _, s in ipairs(msg_lines) do
		max_len = math.max(max_len, vim.fn.strdisplaywidth(s))
	end
	for _, s in ipairs(tail_lines) do
		max_len = math.max(max_len, vim.fn.strdisplaywidth(s))
	end

	local start_lnum = math.max(0, line - 1)
	local end_lnum = end_line and math.max(0, end_line) or start_lnum

	if end_line and end_lnum > start_lnum then
		local buf_lines = vim.api.nvim_buf_get_lines(bufnr, start_lnum, end_lnum, false)
		for _, l in ipairs(buf_lines) do
			max_len = math.max(max_len, vim.fn.strdisplaywidth(l) + textoff)
		end
	end

	local title = opts.title or ""
	local title_len = vim.fn.strdisplaywidth(title)
	local content_width = math.max(title_len + 1, max_len)

	local top_border_str
	if title == "" then
		top_border_str = "╭─" .. string.rep("─", content_width) .. "─╮"
	else
		top_border_str = "╭─ " .. title .. string.rep("─", content_width - title_len - 1) .. "─╮"
	end

	local top_vlines = {
		{ { top_border_str, hl } },
	}
	for _, s in ipairs(msg_lines) do
		local pad = string.rep(" ", content_width - vim.fn.strdisplaywidth(s))
		table.insert(top_vlines, { { "│ " .. s .. pad .. " │", hl } })
	end

	local bottom_vlines = {}
	if end_line then
		for _, s in ipairs(tail_lines) do
			if s ~= "" then
				local pad = string.rep(" ", content_width - vim.fn.strdisplaywidth(s))
				table.insert(bottom_vlines, { { "│ " .. s .. pad .. " │", hl } })
			end
		end
		table.insert(bottom_vlines, { { "╰─" .. string.rep("─", content_width) .. "─╯", hl } })
	else
		table.insert(top_vlines, { { "╰─" .. string.rep("─", content_width) .. "─╯", hl } })
	end

	local is_first_line = start_lnum == 0

	local ok, top_id = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, start_lnum, 0, {
		virt_lines = top_vlines,
		virt_lines_above = not is_first_line,
		virt_lines_leftcol = true,
	})

	if not ok then
		return
	end

	local sign_ids = {}
	local bottom_id = nil

	if end_line then
		local start_sign = is_first_line and 1 or start_lnum
		local right_border_col = content_width + 3 - textoff

		for i = start_sign, end_lnum - 1 do
			local s_ok, sid = pcall(vim.api.nvim_buf_set_extmark, bufnr, connector_ns, i, 0, {
				sign_text = "│",
				sign_hl_group = hl,
				virt_text = { { "│", hl } },
				virt_text_win_col = right_border_col,
			})
			if s_ok then
				table.insert(sign_ids, sid)
			end
		end

		local b_ok, bid = pcall(vim.api.nvim_buf_set_extmark, bufnr, ns, end_lnum, 0, {
			virt_lines = bottom_vlines,
			virt_lines_above = true,
			virt_lines_leftcol = true,
		})
		if b_ok then
			self.bottom_id = bid
		end
	end

	self.id = top_id
	self.sign_ids = sign_ids
	self.is_visible = true
end

function M.add_buffer_message(opts)
	local msg = Message.new(opts)
	msg:show()
	return msg
end

return M
