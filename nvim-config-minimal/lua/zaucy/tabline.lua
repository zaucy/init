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
M._pending_index = nil

M._named_tabs = {
	[homedir] = "",
	[initdir] = "󰒔",
}

local function notify_radnvim()
	local ok, rad = pcall(require, "radnvim")
	if ok and type(rad) == "table" and rad._notify_all then
		rad._notify_all()
	end
end

local function prune_invalid_tabs()
	for index, tabpage in pairs(M._tabs) do
		if not vim.api.nvim_tabpage_is_valid(tabpage) then
			M._tabs[index] = nil
		end
	end
end

local function assign_tab_slot(index, tabpage)
	for k, tp in pairs(M._tabs) do
		if tp == tabpage and k ~= index then
			M._tabs[k] = nil
		end
	end
	M._tabs[index] = tabpage
end

local function save_session_state(force)
	if vim.g.SessionLoad and not force then
		return
	end
	prune_invalid_tabs()
	local slots = {}
	for index, tabpage in pairs(M._tabs) do
		if vim.api.nvim_tabpage_is_valid(tabpage) then
			local tabnr = vim.api.nvim_tabpage_get_number(tabpage)
			slots[tostring(tabnr)] = index
		end
	end
	pcall(function()
		vim.g.ZaucyTablineState = vim.json.encode({
			slots = slots,
			named_tabs = M._named_tabs,
		})
	end)
end

local function restore_session_state()
	local raw = vim.g.ZaucyTablineState
	if type(raw) ~= "string" or raw == "" then
		return
	end
	local ok, decoded = pcall(vim.json.decode, raw)
	if not ok or type(decoded) ~= "table" then
		return
	end

	if type(decoded.named_tabs) == "table" then
		for k, v in pairs(decoded.named_tabs) do
			M._named_tabs[k] = v
		end
	end

	if type(decoded.slots) == "table" then
		local new_tabs = {}
		local tabpages_by_nr = {}
		for _, tp in ipairs(vim.api.nvim_list_tabpages()) do
			if vim.api.nvim_tabpage_is_valid(tp) then
				tabpages_by_nr[tostring(vim.api.nvim_tabpage_get_number(tp))] = tp
			end
		end
		for tabnr_str, slot in pairs(decoded.slots) do
			local slot_num = tonumber(slot)
			local tp = tabpages_by_nr[tostring(tabnr_str)]
			if slot_num and slot_num >= 1 and slot_num <= 9 and tp then
				new_tabs[slot_num] = tp
			end
		end
		if next(new_tabs) ~= nil then
			M._tabs = new_tabs
		end
	end
end

function M.goto(index)
	assert(type(index) == "number")
	assert(index > 0, "Cannot go to tab < 1")
	assert(index < 10, "Cannot go to tab > 9")

	-- local current_tabpage = vim.api.nvim_get_current_tabpage()
	-- if is_empty_tabpage(current_tabpage) then
	-- 	vim.cmd('tabclose')
	-- end

	prune_invalid_tabs()

	if M._tabs[index] ~= nil and vim.api.nvim_tabpage_is_valid(M._tabs[index]) then
		vim.api.nvim_set_current_tabpage(M._tabs[index])
	else
		M._pending_index = index
		vim.cmd('tabnew')
		M._pending_index = nil
		assign_tab_slot(index, vim.api.nvim_get_current_tabpage())
	end

	save_session_state()
	notify_radnvim()
	vim.cmd.redrawtabline()
end

function M.draw()
	local format_fn = vim.g.radnvim_tab_format
	if type(format_fn) ~= "function" then
		return ""
	end

	prune_invalid_tabs()

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
	save_session_state()
	notify_radnvim()
	vim.cmd.redrawtabline()
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
	prune_invalid_tabs()

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

		-- If opened via M.goto(index), assign to the requested slot before auto-assigning
		if not numbered_index and M._pending_index and info.tab == vim.api.nvim_get_current_tabpage() then
			local target = M._pending_index
			M._pending_index = nil
			assign_tab_slot(target, info.tab)
			numbered_index = target
			save_session_state()
		end

		-- Auto-assign new normal tab to lowest available slot (skip while session is mid-load)
		if not numbered_index and not vim.g.SessionLoad then
			for i = 1, 9 do
				if M._tabs[i] == nil or not vim.api.nvim_tabpage_is_valid(M._tabs[i]) then
					assign_tab_slot(i, info.tab)
					numbered_index = i
					save_session_state()
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

vim.api.nvim_create_autocmd("SessionLoadPre", {
	callback = function()
		M._tabs = {}
		local cur_buf = vim.api.nvim_get_current_buf()
		local non_term_bufs = {}
		for _, buf in ipairs(vim.api.nvim_list_bufs()) do
			if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype ~= "terminal" then
				table.insert(non_term_bufs, buf)
			end
		end
		if #non_term_bufs == 1 and is_blank_scratch_buffer(cur_buf) then
			return
		end
		local scratch = vim.api.nvim_create_buf(true, false)
		for _, win in ipairs(vim.api.nvim_list_wins()) do
			if vim.api.nvim_win_is_valid(win) then
				pcall(vim.api.nvim_win_set_buf, win, scratch)
			end
		end
		for _, buf in ipairs(non_term_bufs) do
			if buf ~= scratch and vim.api.nvim_buf_is_valid(buf) then
				pcall(vim.api.nvim_buf_delete, buf, { force = true })
			end
		end
	end,
})

vim.api.nvim_create_autocmd("BufFilePost", {
	callback = function(ev)
		if not vim.g.SessionLoad or vim.b[ev.buf]._session_renaming then
			return
		end
		local name = vim.api.nvim_buf_get_name(ev.buf)
		if name == "" then
			return
		end
		vim.b[ev.buf]._session_target_name = name
		vim.b[ev.buf]._session_renaming = true
		pcall(vim.api.nvim_buf_set_name, ev.buf, "")
		vim.b[ev.buf]._session_renaming = nil
	end,
})

local function restore_session_buffers()
	local by_norm_name = {}
	local restored_any = false
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.b[buf]._session_target_name then
			restored_any = true
			local target = vim.b[buf]._session_target_name
			local norm_target = vim.fs.normalize(target):gsub("/+$", "")
			vim.b[buf]._session_target_name = nil

			local canonical = by_norm_name[norm_target]
			if canonical and vim.api.nvim_buf_is_valid(canonical) then
				for _, win in ipairs(vim.fn.win_findbuf(buf)) do
					if vim.api.nvim_win_is_valid(win) then
						vim.api.nvim_win_set_buf(win, canonical)
					end
				end
				pcall(vim.api.nvim_buf_delete, buf, { force = true })
			else
				for _, other in ipairs(vim.api.nvim_list_bufs()) do
					if other ~= buf and vim.api.nvim_buf_is_valid(other) and not vim.api.nvim_buf_is_loaded(other) then
						local other_name = vim.api.nvim_buf_get_name(other)
						if other_name ~= "" and vim.fs.normalize(other_name):gsub("/+$", "") == norm_target then
							pcall(vim.api.nvim_buf_delete, other, { force = true })
						end
					end
				end
				vim.b[buf]._session_renaming = true
				pcall(vim.api.nvim_buf_set_name, buf, target)
				vim.b[buf]._session_renaming = nil
				by_norm_name[norm_target] = buf
			end
		end
	end
	if restored_any then
		local ok, crude = pcall(require, "crude")
		if ok and crude and crude.load_uninitialized_buffers then
			pcall(crude.load_uninitialized_buffers)
		end
	end
end

vim.api.nvim_create_autocmd("SessionLoadPost", {
	callback = function()
		restore_session_buffers()
		restore_session_state()
		save_session_state(true)
		notify_radnvim()
		vim.cmd.redrawtabline()
		vim.schedule(function()
			restore_session_state()
			save_session_state(true)
			notify_radnvim()
			vim.cmd.redrawtabline()
		end)
	end,
})

vim.api.nvim_create_autocmd({ "UIEnter", "VimEnter" }, {
	callback = function()
		notify_radnvim()
		vim.schedule(function()
			notify_radnvim()
			vim.cmd.redrawtabline()
		end)
	end,
})

vim.api.nvim_create_autocmd("TabClosed", {
	callback = function()
		prune_invalid_tabs()
		save_session_state()
		notify_radnvim()
	end,
})

save_session_state()

return M
