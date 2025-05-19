local function render_multibuf_title(bufnr)
	local icons = require('nvim-web-devicons')
	local buf_name = vim.api.nvim_buf_get_name(bufnr)
	local icon, icon_hl_group = icons.get_icon(buf_name)
	local nice_buf_name = vim.fn.fnamemodify(buf_name, ':~:.')
	nice_buf_name = string.gsub(nice_buf_name, '\\', '/')

	icon = icon or ""
	icon_hl_group = icon_hl_group or "DevIconDefault"

	local title = { { " " }, { icon, icon_hl_group }, { " ", "" }, { nice_buf_name, "MultibufferTitleName" }, { " " } }
	local title_text_length = 0
	for _, part in ipairs(title) do
		title_text_length = title_text_length + string.len(part[1])
	end

	local top_text = "╭" .. string.rep("─", title_text_length - 2) .. "╮"
	local bottom_text = "╰" .. string.rep("─", title_text_length - 2) .. "╯"

	table.insert(title, 1, { "│", "MultibufferTitleBorder" })
	table.insert(title, { "│", "MultibufferTitleBorder" })

	return {
		{ { top_text, "MultibufferTitleBorder" } },
		title,
		{ { bottom_text, "MultibufferTitleBorder" } },
	}
end

return {
	{
		"zaucy/multibuffer.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			local multibuffer = require("multibuffer")
			multibuffer.setup({
				render_multibuf_title = render_multibuf_title,
			})

			vim.api.nvim_set_hl(0, "MultibufferTitleBorder", { link = "FloatBorder" })
			vim.api.nvim_set_hl(0, "MultibufferTitleName", { link = "FloatTitle" })

			vim.api.nvim_create_autocmd("BufWinEnter", {
				pattern = "multibuffer://*",
				callback = function(args)
					local winid = vim.api.nvim_get_current_win()
					vim.api.nvim_set_option_value("number", false, { scope = "local", win = winid })
					vim.api.nvim_set_option_value("relativenumber", false, { scope = "local", win = winid })
				end,
			})
		end,
	}
}
