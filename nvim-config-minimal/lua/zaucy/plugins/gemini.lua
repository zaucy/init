local function nvim_get_messages()
	return vim.api.nvim_exec2("messages", { output = true }).output
end

local function nvim_execute_lua(args)
	local func, err = load(args.code)
	if not func then
		return { error = err }
	end
	local ok, result = pcall(func)
	if not ok then
		return { error = result }
	end
	return { result = result }
end

local function nvim_read_help(args)
	local ok, _ = pcall(vim.cmd.help, args.query)
	if not ok then
		return "Help topic not found: " .. args.query
	end

	local buf = vim.api.nvim_get_current_buf()
	local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
	vim.cmd("close")

	return table.concat(lines, "\n")
end

local mcp = require("mcp")
mcp.setup({})

mcp.register_tool(nvim_get_messages, {
	name = "nvim_get_messages",
	description = "Read the current neovim :messages output",
	inputSchema = {
		type = "object",
	},
})

mcp.register_tool(nvim_execute_lua, {
	name = "nvim_execute_lua",
	description = "Execute Neovim Lua code",
	inputSchema = {
		type = "object",
		properties = {
			code = { type = "string", description = "The lua code to execute" },
		},
		required = { "code" },
	},
})

mcp.register_tool(nvim_read_help, {
	name = "nvim_read_help",
	description = "Open Neovim help for a query",
	inputSchema = {
		type = "object",
		properties = {
			query = { type = "string", description = "The help query" },
		},
		required = { "query" },
	},
})

require("gemini").setup({
	sticky_max_width = 100,
	sticky_max_height = 30,
})

local chat_was_focused_when_opening_gemini_diff = false

vim.api.nvim_create_autocmd("User", {
	pattern = "GeminiOpenDiffPre",
	callback = function()
		chat_was_focused_when_opening_gemini_diff = require("zaucy.chat").chat_is_focused()
		require("zaucy.chat").chat_hide()
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "GeminiOpenDiff",
	callback = function(args)
		vim.keymap.set(
			{ "n", "v" },
			"<leader>aa",
			require("gemini.diff").accept_all_diffs,
			{ buffer = args.data.bufnr, desc = "Accept gemini edit" }
		)
		vim.keymap.set(
			{ "n", "v" },
			"<leader>ad",
			require("gemini.diff").reject_all_diffs,
			{ buffer = args.data.bufnr, desc = "Reject gemini edit" }
		)
		require("zaucy.ui.diff_hint").show_diff_hint()
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "GeminiCloseDiff",
	callback = function(args)
		vim.keymap.del({ "n", "v" }, "<leader>aa", { buffer = args.data.bufnr })
		vim.keymap.del({ "n", "v" }, "<leader>ad", { buffer = args.data.bufnr })
		require("zaucy.ui.diff_hint").close_diff_hint()

		if chat_was_focused_when_opening_gemini_diff then
			require("zaucy.chat").chat_show()
		end
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "ZaucyChatTerminalBufCreated",
	callback = function(args)
		vim.keymap.set({ "t" }, "<C-S-CR>", function()
			vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-\\><C-n>", true, false, true), "n", false)
			require("zaucy.chat").chat_hide()
		end, { buffer = args.data.terminal_bufnr })

		vim.keymap.set({ "t", "n", "v" }, "<C-g>", function()
			require("zaucy.chat").chat_hide()
			require("gemini.diff").focus_next_diff()
		end, { buffer = args.data.terminal_bufnr })

		local forwarded_keys = {
			"<C-d>",
			"<C-u>",
		}

		for _, key in ipairs(forwarded_keys) do
			vim.keymap.set({ "t" }, key, "<C-\\><C-n>" .. key, { buffer = args.data.terminal_bufnr, remap = true })
		end
	end,
})
