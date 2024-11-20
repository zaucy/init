-- Function to check if a buffer is a blank scratch buffer
local function is_blank_scratch_buffer(bufnr)
	local buf_info = vim.fn.getbufinfo(bufnr)[1]
	local buffer_name = vim.api.nvim_buf_get_name(bufnr)
	local buffer_type = vim.bo[bufnr].buftype
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	local first_line = vim.api.nvim_buf_get_lines(bufnr, 0, 1, false)[1] or ""

	return buffer_name == "" and buffer_type == "" and line_count == 1 and first_line == ""
end

local function is_empty_tabpage(tabpage)
	local wins = vim.api.nvim_tabpage_list_wins(tabpage)
	if #wins == 1 then
		return is_blank_scratch_buffer(vim.api.nvim_win_get_buf(wins[1]))
	end
	return false
end

local M = {}

M._index_names = { "󰎦", "󰎩", "󰎬", "󰎮", "󰎰", "󰎵", "󰎸", "󰎻", "󰎾", }
M._index_names_active = { "󰎤", "󰎧", "󰎪", "󰎭", "󰎱", "󰎳", "󰎶", "󰎹", "󰎼" }
M._tabs = { vim.api.nvim_get_current_tabpage() }

function M.goto(index)
	assert(type(index) == "number")
	assert(index > 0, "Cannot go to tab < 1")
	assert(index < 10, "Cannot go to tab > 9")

	local current_tabpage = vim.api.nvim_get_current_tabpage()
	if is_empty_tabpage(current_tabpage) then
		vim.cmd('tabclose')
	end
	vim.cmd('tabnew')

	if M._tabs[index] ~= nil and vim.api.nvim_tabpage_is_valid(M._tabs[index]) then
		vim.api.nvim_set_current_tabpage(M._tabs[index])
	else
		M._tabs[index] = vim.api.nvim_get_current_tabpage()
	end
end

function M.draw()
	local tabs = {}
	local trailing = {}
	local current_tabpage = vim.api.nvim_get_current_tabpage()

	for index, tabpage in pairs(M._tabs) do
		if vim.api.nvim_tabpage_is_valid(tabpage) then
			if tabpage == current_tabpage then
				table.insert(tabs, (M._index_names_active[index] or M._index_names[index] or index))
			else
				table.insert(tabs, (M._index_names[index] or index))
			end
		end
	end

	return table.concat(tabs, ' ')
end

return M