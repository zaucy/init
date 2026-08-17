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

M._named_tabs = {
	[homedir] = "",
	[initdir] = "󰒔",
}

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
	local format_fn = vim.g.radnvim_tab_format
	if type(format_fn) ~= "function" then
		return ""
	end

	for index, tabpage in pairs(M._tabs) do
		if not vim.api.nvim_tabpage_is_valid(tabpage) then
			M._tabs[index] = nil
		end
	end

	local current_tabpage = vim.api.nvim_get_current_tabpage()
	local tabpages = vim.api.nvim_list_tabpages()

	local left_tabs = {}
	local right_tabs = {}

	for _, tabpage in ipairs(tabpages) do
		if vim.api.nvim_tabpage_is_valid(tabpage) then
			local tabnumber = vim.api.nvim_tabpage_get_number(tabpage)
			local is_active = (tabpage == current_tabpage)
			local winid = vim.api.nvim_tabpage_get_win(tabpage)
			local bufnr = vim.api.nvim_win_get_buf(winid)
			local buf_name = vim.api.nvim_buf_get_name(bufnr)
			local cwd = vim.fn.substitute(vim.fn.getcwd(-1, tabnumber), '\\\\', '/', 'g')

			local info = {
				tab = tabpage,
				tab_index = tabnumber,
				is_active = is_active,
				bufnr = bufnr,
				bufname = buf_name,
				cwd = cwd,
			}

			local res = format_fn(info)
			if res then
				local title = ""
				local align = "left"
				local order = tabnumber

				if type(res) == "string" then
					title = res
				elseif type(res) == "table" then
					title = res.title or ""
					align = res.align or "left"
					order = res.order or tabnumber
				end

				if title ~= "" then
					local hl = is_active and "%#TabLineSel#" or "%#TabLine#"
					local tab_str = "%" .. tabnumber .. "T" .. hl .. title .. "%T%*"

					local entry = {
						order = order,
						str = tab_str,
					}

					if align == "right" then
						table.insert(right_tabs, entry)
					else
						table.insert(left_tabs, entry)
					end
				end
			end
		end
	end

	table.sort(left_tabs, function(a, b) return (a.order or 0) < (b.order or 0) end)
	table.sort(right_tabs, function(a, b) return (a.order or 0) < (b.order or 0) end)

	local left_strs = {}
	for _, entry in ipairs(left_tabs) do
		table.insert(left_strs, entry.str)
	end

	local right_strs = {}
	for _, entry in ipairs(right_tabs) do
		table.insert(right_strs, entry.str)
	end

	return table.concat(left_strs, ' ') .. "%=" .. table.concat(right_strs, ' ') .. "%#TabLineFill#%T"
end

function M.set_tab_name(dir, name)
	assert(type(dir) == "string")
	assert(type(name) == "string")

	dir = vim.fn.substitute(vim.fn.expand(dir), '\\\\', '/', 'g')
	M._named_tabs[dir] = name
end

local function is_diffview_tab(tabpage, bufname)
	local dv_ok, dv_lib = pcall(require, "diffview.lib")
	local dv_view = dv_ok and dv_lib.tabpage_to_view(tabpage)
	if dv_view then
		return true, dv_view
	end

	if bufname and vim.startswith(bufname, "diffview://") then
		return true, nil
	end

	if vim.api.nvim_tabpage_is_valid(tabpage) then
		local wins = vim.api.nvim_tabpage_list_wins(tabpage)
		for _, win in ipairs(wins) do
			if vim.api.nvim_win_is_valid(win) then
				local buf = vim.api.nvim_win_get_buf(win)
				if vim.api.nvim_buf_is_valid(buf) then
					local bname = vim.api.nvim_buf_get_name(buf)
					local bft = vim.bo[buf].filetype
					if vim.startswith(bname, "diffview://") or vim.startswith(bft, "Diffview") or bft == "diffview" then
						return true, nil
					end
				end
			end
		end
	end

	return false, nil
end

-- Radnvim native titlebar integration via global configuration
vim.g.radnvim_tab_format = function(info)
	local tabcwd = vim.fn.substitute(info.cwd or vim.fn.getcwd(-1, info.tab_index), '\\\\', '/', 'g')
	local existing_tab_name = M._named_tabs[tabcwd]

	local is_diffview, dv_view = is_diffview_tab(info.tab, info.bufname)
	local buf_name = info.bufname or ""
	local is_codediff = vim.startswith(buf_name, "codediff://")
	local is_health = vim.startswith(buf_name, "health://")
	local is_transient = is_diffview or is_codediff or is_health

	-- If this tabpage is a transient/special tab, make sure it is not in M._tabs
	if is_transient then
		for index, tabpage in pairs(M._tabs) do
			if tabpage == info.tab then
				M._tabs[index] = nil
			end
		end
	end

	-- Check if info.tab belongs to a numbered slot in M._tabs
	local numbered_index = nil
	if not is_transient then
		for index, tabpage in pairs(M._tabs) do
			if tabpage == info.tab then
				numbered_index = index
				break
			end
		end

		-- Auto-assign new normal tab to lowest available slot
		if not numbered_index then
			for i = 1, 9 do
				if M._tabs[i] == nil or not vim.api.nvim_tabpage_is_valid(M._tabs[i]) then
					M._tabs[i] = info.tab
					numbered_index = i
					break
				end
			end
		end
	end

	if numbered_index then
		local num_icon = info.is_active and (M._index_names_active[numbered_index] or M._index_names[numbered_index])
			or (M._index_names[numbered_index] or tostring(numbered_index))
		local title = ""
		if existing_tab_name then
			title = num_icon .. " " .. existing_tab_name
		else
			local base = vim.fn.fnamemodify(tabcwd, ':t')
			if base == '' then base = tabcwd end
			title = num_icon .. " " .. base
		end

		return {
			title = title,
			align = "left",
			order = numbered_index,
		}
	else
		-- Unnumbered / transient tab: anchor to right
		local display_name = ""
		if is_diffview then
			local repo_root = dv_view and dv_view.adapter and dv_view.adapter.ctx and dv_view.adapter.ctx.toplevel
			local repo_name = ""
			if repo_root and repo_root ~= "" then
				repo_root = vim.fn.substitute(repo_root, '\\\\', '/', 'g')
				repo_name = vim.fs.basename(repo_root)
			else
				local root = vim.fs.root(tabcwd, ".git")
				if root then
					root = vim.fn.substitute(root, '\\\\', '/', 'g')
					repo_name = vim.fs.basename(root)
				else
					repo_name = vim.fs.basename(tabcwd)
				end
			end
			if repo_name == "" then repo_name = "diff" end
			display_name = " " .. repo_name
		elseif is_health then
			display_name = " " .. buf_name:sub(10)
		elseif is_codediff then
			display_name = " " .. buf_name:sub(12)
		elseif buf_name ~= "" then
			display_name = vim.fn.fnamemodify(buf_name, ':t')
		elseif existing_tab_name then
			display_name = existing_tab_name
		else
			local base = vim.fn.fnamemodify(tabcwd, ':t')
			if base ~= '' then
				display_name = base
			else
				display_name = "Tab " .. info.tab_index
			end
		end

		return {
			title = display_name,
			align = "right",
			order = 100 + info.tab_index,
		}
	end
end

return M
