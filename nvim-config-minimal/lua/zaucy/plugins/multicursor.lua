local mc_ns = vim.api.nvim_create_namespace("nvim.multicursor")

-- Highlights
vim.api.nvim_set_hl(0, "MCursor", { reverse = true, fg = "#73daca" })
vim.api.nvim_set_hl(0, "MCursorVisual", { link = "Visual" })
vim.api.nvim_set_hl(0, "MultiCursorCursor", { link = "MCursor" })
vim.api.nvim_set_hl(0, "MultiCursorVisual", { link = "MCursorVisual" })

local function clear_cursors()
	vim.api.nvim_buf_clear_namespace(0, mc_ns, 0, -1)
end

local function toggle_or_delete_cursor()
	vim.cmd("normal! Q")
end

-- Clear cursors
vim.keymap.set({ "n", "v" }, ",", clear_cursors, { desc = "Clear multicursors" })
vim.keymap.set({ "n", "v" }, "gm,", clear_cursors, { desc = "Clear multicursors" })

-- Delete / toggle cursor at position
vim.keymap.set({ "n", "v" }, "<A-->", toggle_or_delete_cursor, { desc = "Toggle/delete cursor" })
vim.keymap.set({ "n", "v" }, "gm<A-->", toggle_or_delete_cursor, { desc = "Toggle/delete cursor" })
vim.keymap.set({ "n", "v" }, "gmx", toggle_or_delete_cursor, { desc = "Delete cursor" })

-- Which-key Hydra
vim.keymap.set({ "n", "v" }, "gM", function()
	require("which-key").show({ keys = "gm", loop = true })
end, { desc = "Multicursor Hydra" })

-- Navigation between cursors
vim.keymap.set({ "n", "v" }, "gml", "]C", { remap = true, desc = "Next cursor" })
vim.keymap.set({ "n", "v" }, "gmh", "[C", { remap = true, desc = "Prev cursor" })
vim.keymap.set({ "n", "v" }, "gm<right>", "]C", { remap = true, desc = "Next cursor" })
vim.keymap.set({ "n", "v" }, "gm<left>", "[C", { remap = true, desc = "Prev cursor" })

local function jump_first_cursor()
	local marks = vim.api.nvim_buf_get_extmarks(0, mc_ns, 0, -1, {})
	if #marks > 0 then
		vim.cmd("normal! m'")
		vim.api.nvim_win_set_cursor(0, { marks[1][2] + 1, marks[1][3] })
	end
end

local function jump_last_cursor()
	local marks = vim.api.nvim_buf_get_extmarks(0, mc_ns, 0, -1, {})
	if #marks > 0 then
		vim.cmd("normal! m'")
		vim.api.nvim_win_set_cursor(0, { marks[#marks][2] + 1, marks[#marks][3] })
	end
end

vim.keymap.set({ "n", "v" }, "gm<c-h>", jump_first_cursor, { desc = "First cursor" })
vim.keymap.set({ "n", "v" }, "gm<c-l>", jump_last_cursor, { desc = "Last cursor" })
vim.keymap.set({ "n", "v" }, "gm<c-left>", jump_first_cursor, { desc = "First cursor" })
vim.keymap.set({ "n", "v" }, "gm<c-right>", jump_last_cursor, { desc = "Last cursor" })

-- Match all / Search all
vim.keymap.set({ "n", "v" }, "gmm", "1Q", { remap = true, desc = "Match all add cursors" })
vim.keymap.set({ "n", "v" }, "gm/", function()
	local pat = vim.fn.input("Multicursor search: ")
	if pat and #pat > 0 then
		vim.fn.setreg("/", pat)
		vim.cmd("normal! 1Q")
	end
end, { desc = "Search all add cursors" })

-- Match add cursor next / prev
local function match_add_cursor(forward)
	local cur = vim.api.nvim_win_get_cursor(0)
	local marks = vim.api.nvim_buf_get_extmarks(0, mc_ns, 0, -1, { limit = 1 })
	if #marks == 0 then
		vim.api.nvim_mcursor(0, cur)
	end
	local ok = pcall(vim.cmd, "normal! " .. (forward and "n" or "N"))
	if ok then
		local new_cur = vim.api.nvim_win_get_cursor(0)
		vim.api.nvim_mcursor(0, new_cur)
	end
end

vim.keymap.set({ "n", "v" }, "gmn", function()
	match_add_cursor(true)
end, { desc = "Match add cursor next" })
vim.keymap.set({ "n", "v" }, "gmN", function()
	match_add_cursor(false)
end, { desc = "Match add cursor prev" })

-- Line add cursor
local function line_add_cursor(delta)
	local cur = vim.api.nvim_win_get_cursor(0)
	local target_line = cur[1] + delta
	local line_count = vim.api.nvim_buf_line_count(0)
	if target_line >= 1 and target_line <= line_count then
		vim.api.nvim_mcursor(0, cur)
		local line_len = #vim.api.nvim_buf_get_lines(0, target_line - 1, target_line, false)[1]
		local col = math.min(cur[2], line_len)
		vim.api.nvim_win_set_cursor(0, { target_line, col })
	end
end

vim.keymap.set({ "n", "v" }, "gmj", function()
	line_add_cursor(1)
end, { desc = "Add cursor next line" })
vim.keymap.set({ "n", "v" }, "gmk", function()
	line_add_cursor(-1)
end, { desc = "Add cursor prev line" })
vim.keymap.set({ "n", "v" }, "gm<down>", function()
	line_add_cursor(1)
end, { desc = "Add cursor next line" })
vim.keymap.set({ "n", "v" }, "gm<up>", function()
	line_add_cursor(-1)
end, { desc = "Add cursor prev line" })

-- Follow mode toggle ("q=" native follow-mode)
vim.keymap.set("n", "gmo", "q=", { remap = true, desc = "Toggle follow-mode (motions affect all cursors)" })
vim.keymap.set("v", "gmo", "q=", { remap = true, desc = "Toggle follow-mode (motions affect all cursors)" })

-- Restore previous session & Ascending counter
vim.keymap.set({ "n", "v" }, "gmr", "gQ", { remap = true, desc = "Restore previous multicursors" })
vim.keymap.set({ "n", "v" }, "gm#", "g<C-A>", { remap = true, desc = "Insert ascending counter" })

-- Motions: add cursor and move primary
local function motion_add_cursor(motion)
	local cur = vim.api.nvim_win_get_cursor(0)
	vim.api.nvim_mcursor(0, cur)
	vim.cmd("normal! " .. motion)
end

vim.keymap.set("n", "gm%", function()
	motion_add_cursor("%")
end, { desc = "Add cursor to match" })
vim.keymap.set("n", "gmw", function()
	motion_add_cursor("w")
end, { desc = "Add cursor next word" })
vim.keymap.set("n", "gmW", function()
	motion_add_cursor("W")
end, { desc = "Add cursor next WORD" })
vim.keymap.set("n", "gmb", function()
	motion_add_cursor("b")
end, { desc = "Add cursor prev word" })
vim.keymap.set("n", "gmB", function()
	motion_add_cursor("B")
end, { desc = "Add cursor prev WORD" })
vim.keymap.set("n", "gme", function()
	motion_add_cursor("e")
end, { desc = "Add cursor end of word" })
vim.keymap.set("n", "gmE", function()
	motion_add_cursor("E")
end, { desc = "Add cursor end of WORD" })
vim.keymap.set("n", "gm$", function()
	motion_add_cursor("$")
end, { desc = "Add cursor end of line" })
vim.keymap.set("n", "gm0", function()
	motion_add_cursor("0")
end, { desc = "Add cursor start of line" })

local function char_motion_add_cursor(motion)
	local char = vim.fn.getcharstr()
	if char and #char > 0 and char ~= "\27" then
		motion_add_cursor(motion .. char)
	end
end

vim.keymap.set("n", "gmf", function()
	char_motion_add_cursor("f")
end, { desc = "Add cursor at next char" })
vim.keymap.set("n", "gmF", function()
	char_motion_add_cursor("F")
end, { desc = "Add cursor at prev char" })
vim.keymap.set("n", "gmt", function()
	char_motion_add_cursor("t")
end, { desc = "Add cursor before next char" })
vim.keymap.set("n", "gmT", function()
	char_motion_add_cursor("T")
end, { desc = "Add cursor before prev char" })

-- mcos integration
local mcos = require("mcos")
mcos.setup({})
vim.keymap.set({ "n", "v" }, "gms", mcos.opkeymapfunc, { expr = true, desc = "MCOS operator" })
vim.keymap.set({ "n" }, "gmss", mcos.bufkeymapfunc, { desc = "MCOS buffer" })
