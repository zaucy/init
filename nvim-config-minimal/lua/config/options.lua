vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.g.terminal_emulator = "nu"
-- NOTE: I tried to use nu but too many plugins rely on the default shell being bash or cmd on Windows
-- vim.go.shell = "nu"
-- vim.go.shellcmdflag = "-c"
-- vim.go.shellquote = "'"
vim.opt.guifont = "FiraCode Nerd Font"
vim.opt.colorcolumn = {}
vim.opt.swapfile = false
vim.opt.shadafile = "NONE" -- shadafiles are annoying and I never find them useful

vim.opt.wrap = false
vim.opt.cursorline = true
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.list = true
vim.opt.listchars = { space = ' ', tab = '\u{ebf9} ', trail = '·', lead = '·' }

vim.opt.showtabline = 2
vim.opt.tabline = "%!v:lua.require'zaucy.tabline'.draw()"

-- Auto reload files when they change
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI", "FocusGained" }, {
	command = "if mode() != 'c' | checktime | endif",
	pattern = { "*" },
})

vim.filetype.add({ extension = { nu = "nu" } })
vim.filetype.add({ extension = { bazelrc = "bazelrc" } })
vim.filetype.add({ extension = { cpp2 = "cpp2" } })
vim.filetype.add({ extension = { ecsact = "ecsact" } })

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
	vim.lsp.diagnostic.on_publish_diagnostics, {
		underline = true,
		signs = false,
		update_in_insert = false,
	}
)

if vim.g.neovide then
	-- scale factors that leave no space on the left/right with my preferred
	-- font and resolution
	-- TODO: somehow calculate this
	local scale_factors = {
		0.9133,
		1.0365,
		1.1032,
		1.2807,
		1.4377,
	}

	local function find_closest_current_scale_factor()
		local closest_index = 1;
		for i, v in ipairs(scale_factors) do
			local dist = math.abs(v - vim.g.neovide_scale_factor)
			local current_closest_dist = math.abs(scale_factors[closest_index] - vim.g.neovide_scale_factor)

			if dist < current_closest_dist then
				closest_index = i
			end
		end

		return closest_index
	end

	local function refresh_scale_factor()
		vim.opt.guifont = vim.opt.guifont
	end

	vim.g.neovide_scroll_animation_length = 0
	vim.g.neovide_hide_mouse_when_typing = true
	vim.g.neovide_cursor_animation_length = 0.04
	vim.g.neovide_cursor_trail_size = 0.4
	vim.g.neovide_position_animation_length = 0
	vim.g.neovide_fullscreen = false
	vim.g.experimental_layer_grouping = true
	vim.g.neovide_floating_corner_radius = 0.5

	local default_scale_index = 3
	vim.g.neovide_scale_factor = scale_factors[default_scale_index]

	vim.keymap.set(
		"n",
		"<C-=>",
		function()
			local next_index = find_closest_current_scale_factor() + 1
			if next_index <= #scale_factors then
				vim.g.neovide_scale_factor = scale_factors[next_index]
				refresh_scale_factor()
			end
		end,
		{ expr = true }
	)
	vim.keymap.set(
		"n",
		"<C-->",
		function()
			local prev_index = find_closest_current_scale_factor() - 1;
			if prev_index > 0 then
				vim.g.neovide_scale_factor = scale_factors[prev_index]
				refresh_scale_factor()
			end
		end,
		{ expr = true }
	)
	vim.keymap.set(
		"n",
		"<C-0>",
		function()
			vim.g.neovide_scale_factor = scale_factors[default_scale_index]
			refresh_scale_factor()
		end,
		{ expr = true }
	)
	vim.api.nvim_set_keymap(
		"n",
		"<F11>",
		":lua vim.g.neovide_fullscreen = !vim.g.neovide_fullscreen<CR>",
		{ silent = true }
	)
end

vim.api.nvim_create_autocmd('TextYankPost', {
	callback = function()
		vim.highlight.on_yank({ timeout = 90 })
	end,
})

vim.api.nvim_create_autocmd('InsertEnter', {
	callback = function()
		if vim.bo.buftype == "nofile" then return end
		if vim.bo.buftype == "terminal" then return end
		if vim.bo.buftype == "prompt" then return end
		if vim.bo.buftype == "acwrite" then return end

		vim.opt.relativenumber = false
	end,
})
vim.api.nvim_create_autocmd('InsertLeave', {
	callback = function()
		if vim.bo.buftype == "nofile" then return end
		if vim.bo.buftype == "terminal" then return end
		if vim.bo.buftype == "prompt" then return end
		if vim.bo.buftype == "acwrite" then return end

		vim.opt.relativenumber = true
	end,
})
vim.api.nvim_create_autocmd({ 'BufEnter', 'BufNew', 'BufWinEnter', 'TermOpen' }, {
	callback = function()
		if vim.bo.buftype == "nofile" then return end
		if vim.bo.buftype == "prompt" then return end
		if vim.bo.buftype == "acwrite" then return end

		if vim.bo.buftype == "terminal" then
			vim.wo.signcolumn = "no"
			vim.wo.number = false
			vim.wo.relativenumber = false
		else
			vim.wo.signcolumn = "auto:1-9"
			vim.wo.number = true
			vim.wo.relativenumber = true
		end
	end,
})
