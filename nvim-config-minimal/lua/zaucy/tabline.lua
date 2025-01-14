local homedir = vim.fn.substitute(vim.fn.expand('~'), '\\\\', '/', 'g')
local initdir = vim.fn.substitute(vim.fn.expand('~/projects/zaucy/init'), '\\\\', '/', 'g')

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

	-- local current_tabpage = vim.api.nvim_get_current_tabpage()
	-- if is_empty_tabpage(current_tabpage) then
	-- 	vim.cmd('tabclose')
	-- end

	if M._tabs[index] ~= nil and vim.api.nvim_tabpage_is_valid(M._tabs[index]) then
		vim.api.nvim_set_current_tabpage(M._tabs[index])
	else
		vim.cmd('tabnew')
		M._tabs[index] = vim.api.nvim_get_current_tabpage()
	end
end

function M.draw()
	local tabs = {}
	local trailing = {}
	local current_tabpage = vim.api.nvim_get_current_tabpage()

	for index, tabpage in pairs(M._tabs) do
		if vim.api.nvim_tabpage_is_valid(tabpage) then
			local tabnumber = vim.api.nvim_tabpage_get_number(tabpage)
			local tab_name = ""
			if tabpage == current_tabpage then
				tab_name = "%#TabLineSel#" .. (M._index_names_active[index] or M._index_names[index] or index)
			else
				tab_name = "%#TabLine#" .. (M._index_names[index] or index)
			end
			local tabcwd = vim.fn.substitute(vim.fn.getcwd(-1, tabnumber), '\\\\', '/', 'g')
			if tabcwd == homedir then
				tab_name = tab_name .. ""
			elseif tabcwd == initdir then
				tab_name = tab_name .. "󰒔"
			else
				tab_name = tab_name .. " " .. vim.fs.basename(tabcwd)
			end
			table.insert(tabs, tab_name .. "%*")
		end
	end

	return table.concat(tabs, ' ')
end

return M
