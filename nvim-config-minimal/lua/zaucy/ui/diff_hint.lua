local M = {}

function M.close_diff_hint()
	if _G.zaucy.diff_hint_win_id and vim.api.nvim_win_is_valid(_G.zaucy.diff_hint_win_id) then
		vim.api.nvim_win_close(_G.zaucy.diff_hint_win_id, true)
	end
	if _G.zaucy.diff_hint_buf_id and vim.api.nvim_buf_is_valid(_G.zaucy.diff_hint_buf_id) then
		vim.api.nvim_buf_delete(_G.zaucy.diff_hint_buf_id, { force = true })
	end
	_G.zaucy.diff_hint_win_id = nil
	_G.zaucy.diff_hint_buf_id = nil
end

function M.show_diff_hint()
	M.close_diff_hint()

	local text = "<leader>aa:  accept | <leader>ad:  reject"
	local bufnr = vim.api.nvim_create_buf(false, true)
	_G.zaucy.diff_hint_buf_id = bufnr

	local width = vim.api.nvim_win_get_width(0)
	local padding = math.max(0, math.floor((width - #text) / 2))
	local centered_text = string.rep(" ", padding) .. text

	vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, { "", centered_text, "" })

	--- @type vim.api.keyset.win_config
	local opts = {
		relative = "win",
		win = 0,
		row = vim.api.nvim_win_get_height(0) - 3,
		col = 0,
		width = width,
		height = 3,
		style = "minimal",
		border = "none",
		focusable = false,
		zindex = 150,
	}

	_G.zaucy.diff_hint_win_id = vim.api.nvim_open_win(bufnr, false, opts)
end

return M
