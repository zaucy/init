local utils = require('telescope.utils')
local entry_display = require('telescope.pickers.entry_display')

local get_filename_fn = function()
	local bufnr_name_cache = {}
	return function(bufnr)
		bufnr = vim.F.if_nil(bufnr, 0)
		local c = bufnr_name_cache[bufnr]
		if c then
			return c
		end

		local n = vim.api.nvim_buf_get_name(bufnr)
		bufnr_name_cache[bufnr] = n
		return n
	end
end

local M = {}

local symbol_table = {
	["array"] = { "", "Array" },
	["boolean"] = { "", "@lsp.type.boolean" },
	["class"] = { "", "@lsp.type.class" },
	["constant"] = { "", "@constant" },
	["constructor"] = { "", "@constructor" },
	["enum"] = { "", "@lsp.type.enum" },
	["enummember"] = { "", "@lsp.type.enumMember" },
	["event"] = { "", "@lsp.type.event" },
	["field"] = { "", "@field" },
	["file"] = "",
	["function"] = { "", "@function" },
	["interface"] = { "", "@lsp.type.interface" },
	["key"] = { "", "@lsp.type.keyword" },
	["method"] = { "", "@method" },
	["module"] = { "", "@module" }, 
	["namespace"] = { "", "@namespace" },
	["null"] = "󰟢",
	["number"] = { "", "@number" },
	["object"] = { "", },
	["operator"] = { "", "@lsp.type.operator" },
	["package"] = { "", "@namespace", },
	["property"] = { "", "@property" },
	["string"] = { "", "@string" },
	["struct"] = { "", "@lsp.type.struct" },
	["typeparameter"] = { "", "@lsp.type.typeParameter" },
	["variable"] = { "", "@variable" },
}

function M.make_entry_symbols(opts)
	opts = opts or {}

	local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()

	local display_items = {
		{ with = 4 },
		{ remaining = true },
	}

	local displayer = entry_display.create {
		separator = " ",
		hl_chars = { ["["] = "TelescopeBorder", ["]"] = "TelescopeBorder" },
		items = display_items,
	}
	local type_highlight = vim.F.if_nil(opts.symbol_highlights or lsp_type_highlight)

	local make_display = function(entry)
		return displayer {
			symbol_table[entry.symbol_type:lower()] or "󱔁",
			entry.symbol_name,
		}
	end

	local get_filename = get_filename_fn()
	return function(entry)
		local filename = vim.F.if_nil(entry.filename, get_filename(entry.bufnr))
		local symbol_msg = entry.text
		local symbol_type, symbol_name = symbol_msg:match "%[(.+)%]%s+(.*)"
		symbol_type = symbol_type:lower() or "unknown"
		local ordinal = filename .. " "
		ordinal = ordinal .. symbol_name .. " " .. symbol_type
		return {
			value = entry,
			ordinal = ordinal,
			display = make_display,

			filename = filename,
			lnum = entry.lnum,
			col = entry.col,
			symbol_name = symbol_name,
			symbol_type = symbol_type,
		}
	end
end

return M
