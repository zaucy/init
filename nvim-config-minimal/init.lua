_G.zaucy = {}

require("config.options")
require("config.lazy")
require("config.keymaps")
require("zaucy.term")
require("zaucy.treesitter-parsers")
require("zaucy.screenshot")

require("zaucy.chat").setup({
	chat_scratch_dir = vim.fn.substitute(vim.fn.expand("~/projects/zaucy/init/scratch/chat"), "\\\\", "/", "g"),
	terminal_command = "gemini",
})

vim.api.nvim_create_autocmd("User", {
	pattern = "McpServerCreated",
	callback = function(args)
		local cwd = args.data.cwd
		require("zaucy.chat").set_dir_loading(cwd, true)
	end,
})

vim.api.nvim_create_autocmd("User", {
	pattern = "McpServerReady",
	callback = function(args)
		local cwd = args.data.cwd
		require("zaucy.chat").set_dir_loading(cwd, false)
	end,
})
