local separator = require("agy.ui.separator")
local agy = require("agy")

agy.setup({
	ui = {
		-- separator = separator.box("rounded"),
		separator = separator.line(),
		verbosity = "medium",
	},
})

agy.register_mention({
	name = "callstack",
	description = "RAD debugger active callstack",
	priority = 95,
	complete = function(query, ctx)
		local ok, radnvim = pcall(require, "radnvim")
		if not ok or type(radnvim.get_callstack) ~= "function" then
			return {}
		end
		local stack = radnvim.get_callstack()
		if not stack or #stack == 0 then
			return {}
		end

		local q = (query or ""):lower()
		if q == "" or ("callstack"):find(q, 1, true) == 1 or q:find("call", 1, true) or q:find("stack", 1, true) then
			local top = stack[1]
			local top_loc = ""
			if top then
				local func = (top.function_name and top.function_name ~= "") and top.function_name or "???"
				local file_tail = (top.file and top.file ~= "") and vim.fn.fnamemodify(top.file, ":t")
					or (top.module or "")
				local loc = (top.line and top.line > 0) and string.format("%s:%d", file_tail, top.line) or file_tail
				top_loc = string.format(" · %s at %s", func, loc)
			end
			return {
				{
					label = "callstack",
					kind = "Debugger",
					detail = string.format("%d frame(s)%s", #stack, top_loc),
					insert_text = "@callstack ",
					priority = 95,
				},
			}
		end
		return {}
	end,
	resolve = function(raw, ctx)
		if raw ~= "callstack" then
			return nil
		end
		local ok, radnvim = pcall(require, "radnvim")
		if not ok or type(radnvim.get_callstack) ~= "function" then
			return nil
		end
		local stack = radnvim.get_callstack()
		if not stack or #stack == 0 then
			return {
				raw = "callstack",
				kind = "DebuggerCallstack",
				content = "No active debugger callstack (target process is not halted or not running).",
			}
		end

		local lines = {}
		local exec_state = (type(radnvim.get_execution_state) == "function") and radnvim.get_execution_state() or nil
		if exec_state and exec_state.status and exec_state.status ~= "none" then
			local status_str = exec_state.status
			if exec_state.cause and exec_state.cause ~= "" then
				status_str = status_str .. " (" .. exec_state.cause .. ")"
			end
			local thread_str = exec_state.thread_id and ("Thread " .. tostring(exec_state.thread_id) .. " · ") or ""
			table.insert(lines, string.format("Debugger State: %s%s", thread_str, status_str))
			table.insert(lines, "")
		end

		table.insert(lines, string.format("Call Stack (%d frames):", #stack))
		for _, f in ipairs(stack) do
			local marker = f.is_active and "▶ " or "  "
			local func = (f.function_name and f.function_name ~= "") and f.function_name or "???"
			local loc = ""
			if f.file and f.file ~= "" then
				local file_norm = vim.fs.normalize(f.file)
				loc = file_norm
					.. (f.line and f.line > 0 and (":" .. f.line .. (f.col and f.col > 0 and (":" .. f.col) or "")) or "")
			elseif f.module and f.module ~= "" then
				loc = f.module
			end

			local ip_str = ""
			if f.ip then
				if type(f.ip) == "number" then
					ip_str = string.format(" [ip: 0x%012x]", f.ip)
				else
					ip_str = string.format(" [ip: %s]", tostring(f.ip))
				end
			end

			local mod_str = (f.module and f.module ~= "" and f.file and f.file ~= "")
					and string.format(" (%s)", f.module)
				or ""

			if loc ~= "" then
				table.insert(
					lines,
					string.format(
						"%s#%-2d %s at %s%s%s",
						marker,
						f.index or f.unwind_count or 0,
						func,
						loc,
						mod_str,
						ip_str
					)
				)
			else
				table.insert(
					lines,
					string.format(
						"%s#%-2d %s%s%s",
						marker,
						f.index or f.unwind_count or 0,
						func,
						mod_str,
						ip_str
					)
				)
			end
		end

		return {
			raw = "callstack",
			kind = "DebuggerCallstack",
			content = table.concat(lines, "\n"),
		}
	end,
})
