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
