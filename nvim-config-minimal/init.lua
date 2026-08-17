_G.zaucy = {}

if not vim.g.radnvim then
	require("vim._core.ui2").enable({})
end
require("config.options")
require("config.keymaps")
require("zaucy.plugins")
require("zaucy.term")
require("zaucy.treesitter-parsers")
require("zaucy.screenshot")
require("zaucy.tabline")
