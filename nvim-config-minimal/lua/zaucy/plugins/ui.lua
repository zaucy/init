require("dressing").setup({})
require("fidget").setup({})
require("snacks").setup({})
require("floaterm").setup({})

local orig_select = vim.ui.select
vim.ui.select = function(...)
	local ok, radnvim = pcall(require, "radnvim")
	if ok and radnvim.ui and radnvim.ui.select then
		return radnvim.ui.select(...)
	end
	return orig_select(...)
end

