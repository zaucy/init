local function render_multibuf_title(bufnr)
	local icons = require("nvim-web-devicons")
	local buf_name = vim.api.nvim_buf_get_name(bufnr)
	local icon, icon_hl_group = icons.get_icon(buf_name)
	local nice_buf_name = vim.fn.fnamemodify(buf_name, ":~:.")
	nice_buf_name = string.gsub(nice_buf_name, "\\", "/")

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
		dir = "~/projects/zaucy/multibuffer.nvim",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		init = function()
			vim.g.multibuffer_expander_max_lines = 3
		end,
		config = function()
			local multibuffer = require("multibuffer")
			multibuffer.setup({
				render_multibuf_title = render_multibuf_title,
			})

			vim.api.nvim_set_hl(0, "MultibufferTitleBorder", { link = "FloatBorder" })
			vim.api.nvim_set_hl(0, "MultibufferTitleName", { link = "FloatTitle" })

			local function open_source_buf(mbuf)
				local winid = vim.api.nvim_get_current_win()
				local cursor = vim.api.nvim_win_get_cursor(winid)
				local winline = vim.fn.winline()

				local buf, line = multibuffer.multibuf_get_buf_at_line(mbuf, cursor[1])
				if buf then
					vim.api.nvim_set_current_buf(buf)
					vim.api.nvim_win_set_cursor(0, { line, cursor[2] })
					vim.fn.winrestview({ topline = line - winline + 1 })
				end
			end

			vim.api.nvim_create_autocmd("FileType", {
				pattern = "multibuffer",
				callback = function(args)
					vim.bo[args.buf].tabstop = 4
					vim.bo[args.buf].shiftwidth = 4
					vim.bo[args.buf].softtabstop = 4
					vim.bo[args.buf].expandtab = false

					vim.keymap.set("n", "<cr>", function()
						open_source_buf(args.buf)
					end, { buffer = args.buf, desc = "Jump to source" })

					vim.keymap.set("n", "<C-up>", function()
						multibuffer.multibuf_slice_expand_top(args.buf, 1)
					end)

					vim.keymap.set("n", "<C-S-up>", function()
						multibuffer.multibuf_slice_expand_bottom(args.buf, -1)
					end)

					vim.keymap.set("n", "<C-down>", function()
						multibuffer.multibuf_slice_expand_bottom(args.buf, 1)
					end)

					vim.keymap.set("n", "<C-S-down>", function()
						multibuffer.multibuf_slice_expand_top(args.buf, -1)
					end)
				end,
			})

			vim.api.nvim_create_autocmd("BufWinEnter", {
				callback = function(args)
					if vim.bo[args.buf].filetype == "multibuffer" then
						local winid = vim.api.nvim_get_current_win()
						vim.api.nvim_set_option_value("number", false, { scope = "local", win = winid })
						vim.api.nvim_set_option_value("relativenumber", false, { scope = "local", win = winid })
						vim.api.nvim_set_option_value("signcolumn", "yes:3", { scope = "local", win = winid })
					end
				end,
			})

			vim.keymap.set({ "n", "v" }, "<C-w>/", function()
				local word = vim.fn.expand("<cword>")
				require("multibuffer.plugins.ripgrep").multibuf_ripgrep({ default_input = word })
			end, { desc = "open search window" })
		end,
	},
}
