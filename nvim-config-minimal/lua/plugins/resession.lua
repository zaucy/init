return {
	"stevearc/resession.nvim",
	keys = {},
	config = function()
		local resession = require("resession")
		resession.setup({
			buf_filter = function(bufnr)
				local buftype = vim.bo[bufnr].buftype
				local filetype = vim.bo[bufnr].filetype
				if buftype == "help" then
					return true
				end
				if buftype == "terminal" then
					return true
				end
				if filetype == "oil" then
					return true
				end
				if buftype ~= "" and buftype ~= "acwrite" then
					return false
				end
				if vim.api.nvim_buf_get_name(bufnr) == "" then
					return false
				end
				return vim.bo[bufnr].buflisted
			end
		})
		resession.load_extension("overseer", {})
	end,
}
