local utils = require("telescope.utils")
local protocol = require("vim.lsp.protocol")
local entry_display = require("telescope.pickers.entry_display")
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local channel = require("plenary.async.control").channel
local sorters = require("telescope.sorters")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local themes = require("telescope.themes")

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
	["object"] = { "" },
	["operator"] = { "", "@lsp.type.operator" },
	["package"] = { "", "@namespace" },
	["property"] = { "", "@property" },
	["string"] = { "", "@string" },
	["struct"] = { "", "@lsp.type.struct" },
	["typeparameter"] = { "", "@lsp.type.typeParameter" },
	["variable"] = { "", "@variable" },
}

-- originally from https://github.com/neovim/neovim/blob/master/runtime/lua/vim/lsp/util.lua#L1812
-- modified to use 'containerName'
local function workspace_symbols_to_items(symbols, bufnr)
	bufnr = bufnr or 0
	local items = {} --- @type vim.quickfix.entry[]
	for _, symbol in ipairs(symbols) do
		--- @type string?, lsp.Position?
		local filename, pos

		if symbol.location then
			--- @cast symbol lsp.SymbolInformation
			filename = vim.uri_to_fname(symbol.location.uri)
			pos = symbol.location.range.start
		elseif symbol.selectionRange then
			--- @cast symbol lsp.DocumentSymbol
			filename = vim.api.nvim_buf_get_name(bufnr)
			pos = symbol.selectionRange.start
		end

		if filename and pos then
			local kind = protocol.SymbolKind[symbol.kind] or "Unknown"
			local full_symbol_name = symbol.name
			if symbol.containerName and #symbol.containerName > 0 then
				full_symbol_name = symbol.containerName .. "::" .. full_symbol_name
			end
			items[#items + 1] = {
				filename = filename,
				lnum = pos.line + 1,
				col = pos.character + 1,
				kind = kind,
				text = "[" .. kind .. "] " .. full_symbol_name,
			}
		end

		if symbol.children then
			vim.list_extend(items, M.symbols_to_items(symbol.children, bufnr))
		end
	end

	return items
end

-- originally from https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/builtin/__lsp.lua#L292
local symbols_sorter = function(symbols)
	if vim.tbl_isempty(symbols) then
		return symbols
	end

	local current_buf = vim.api.nvim_get_current_buf()

	-- sort adequately for workspace symbols
	local filename_to_bufnr = {}
	for _, symbol in ipairs(symbols) do
		if filename_to_bufnr[symbol.filename] == nil then
			filename_to_bufnr[symbol.filename] = vim.uri_to_bufnr(vim.uri_from_fname(symbol.filename))
		end
		symbol.bufnr = filename_to_bufnr[symbol.filename]
	end

	table.sort(symbols, function(a, b)
		if a.bufnr == b.bufnr then
			return a.lnum < b.lnum
		end
		if a.bufnr == current_buf then
			return true
		end
		if b.bufnr == current_buf then
			return false
		end
		return a.bufnr < b.bufnr
	end)

	return symbols
end

-- original from https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/builtin/__lsp.lua#L418
-- modified to use workspace_symbols_to_items
local function get_workspace_symbols_requester(bufnr, opts)
	local cancel = function() end

	return function(prompt)
		local tx, rx = channel.oneshot()
		cancel()
		cancel = vim.lsp.buf_request_all(bufnr, "workspace/symbol", { query = prompt }, tx)

		local results = rx() ---@type table<integer, {error: lsp.ResponseError?, result: lsp.WorkspaceSymbol?}>
		local locations = {} ---@type vim.lsp.util.locations_to_items.ret[]

		for _, client_res in pairs(results) do
			if client_res.error then
				vim.api.nvim_err_writeln("Error when executing workspace/symbol : " .. client_res.error.message)
			elseif client_res.result ~= nil then
				vim.list_extend(locations, workspace_symbols_to_items(client_res.result, bufnr))
			end
		end

		if not vim.tbl_isempty(locations) then
			locations = utils.filter_symbols(locations, opts, symbols_sorter) or {}
		end
		return locations
	end
end

function M.make_entry_symbols(opts)
	opts = opts or {}

	local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()

	local display_items = {
		{ with = 4 },
		{ remaining = true },
	}

	local displayer = entry_display.create({
		separator = " ",
		hl_chars = { ["["] = "TelescopeBorder", ["]"] = "TelescopeBorder" },
		items = display_items,
	})

	local make_display = function(entry)
		return displayer({
			symbol_table[entry.symbol_type:lower()] or "󱔁",
			entry.symbol_name,
		})
	end

	local get_filename = get_filename_fn()
	return function(entry)
		local filename = vim.F.if_nil(entry.filename, get_filename(entry.bufnr))
		local symbol_msg = entry.text
		local symbol_type, symbol_name = symbol_msg:match("%[(.+)%]%s+(.*)")
		symbol_type = symbol_type:lower() or "unknown"
		local ordinal = symbol_name .. " " .. symbol_type
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

function M.dynamic_workspace_symbols(opts)
	local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
	local picker = pickers.new(
		opts,
		themes.get_ivy({
			prompt_title = "Workspace Symbols",
			finder = finders.new_dynamic({
				entry_maker = M.make_entry_symbols(opts),
				fn = get_workspace_symbols_requester(bufnr, opts),
			}),
			previewer = conf.qflist_previewer(opts),
			sorter = sorters.highlighter_only(opts),
			attach_mappings = function(_, map)
				map("i", "<c-space>", actions.to_fuzzy_refine)
				return true
			end,
		})
	)

	picker:find()
end

return M
