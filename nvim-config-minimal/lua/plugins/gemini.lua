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

return {
	{
		"zaucy/mcp.nvim",
		-- dir = "~/projects/zaucy/mcp.nvim",
		config = function()
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
		end,
	},
	{
		"zaucy/gemini.nvim",
		-- dir = "~/projects/zaucy/gemini.nvim",
		build = "bun install -g @google/gemini-cli@nightly",
		dependencies = {
			"zaucy/mcp.nvim",
		},
		opts = {},
	},
}
