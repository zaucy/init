local M = {}

M._tabs = {}

function M._sort_tabs()
	table.sort(M._tabs, function()
	end)
end

function M.get_index(tabpage)
	return M._tabs[tabpage] or nil
end

function M.get_tabpage(index)
	assert(index > 0, "Cannot go to tab < 1")
	assert(index < 10, "Cannot go to tab > 9")

	for tabpage = 1, vim.fn.tabpagenr('$') do
		if M._tabs[tabpage] ~= nil then
			return tabpage
		end
	end

	return nil
end

function M.goto(index)
	assert(index > 0, "Cannot go to tab < 1")
	assert(index < 10, "Cannot go to tab > 9")

	local tabpage = M.get_tabpage(index)
	if tabpage ~= nil then
		vim.api.nvim_set_current_tabpage(tabpage)
	else
		vim.cmd("tabnew")
		tabpage = vim.api.nvim_get_current_tabpage()
		M._tabs[tabpage] = index
	end
end

function M.draw()
	local tabs = {}
	local tailing = {}
	for tabpage = 1, vim.fn.tabpagenr('$') do
		local index = M.get_index(tabpage)
		if index ~= nil then
			if tabpage == vim.api.nvim_tabpage_get_number(0) then
				table.insert(tabs, '%#TabLineSel#[' .. tabpage .. ']%#TabLine#%#TabLineFill#')
			else
				table.insert(tabs, ' ' .. tabpage .. ' ')
			end
		else
				table.insert(tabs, ' ?' .. tabpage .. '? ')
		end
	end
	return table.concat(tabs, ' ')
end

return M
