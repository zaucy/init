--- @param cmp blink.cmp.API
local function is_at_end_of_completion(cmp)
	local ctx = cmp.get_context()
	if not ctx then
		return false
	end

	local prefix = ctx.get_bounds("prefix")
	local full = ctx.get_bounds("full")

	-- TODO: theres probably a way better way to do this, but the
	-- goal is to only accept if my cursor is at the end of the
	-- completion prefix
	if prefix.length == full.length then
		return true
	end

	return false
end

--- @param cmp blink.cmp.API
local function accept_if_at_end(cmp)
	if is_at_end_of_completion(cmp) then
		return cmp.accept()
	end
	return false
end

--- @param cmp blink.cmp.API
local function cancel_if_at_end(cmp)
	if is_at_end_of_completion(cmp) then
		-- purposely let it go to fallback no matter what
		cmp.cancel()
	end
	return false
end

require("blink.cmp").setup({
	keymap = {
		preset = "default",
		["<Up>"] = { "select_prev", "fallback" },
		["<Down>"] = { "select_next", "fallback" },
		["<C-Space>"] = { "show" },
		["<C-k>"] = { "show_documentation" },
		["<C-s>"] = { "show_signature" },
		["<Right>"] = { accept_if_at_end, "fallback" },
		["<C-l>"] = { accept_if_at_end, "fallback" },
		["<Left>"] = { cancel_if_at_end, "fallback" },
		["<C-h>"] = { cancel_if_at_end, "fallback" },
	},
	signature = {
		enabled = true,
	},
	completion = {
		list = {
			selection = {
				auto_insert = false,
				preselect = true,
			},
		},
		documentation = {
			auto_show = false,
		},
		ghost_text = {
			enabled = true,
			show_with_menu = true,
			show_with_selection = true,
			show_without_selection = true,
			show_without_menu = true,
		},
	},
	sources = { default = { "lsp", "path", "snippets", "buffer" } },
	fuzzy = { implementation = "lua" },
})
