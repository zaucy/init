local cmp = require 'cmp'

local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
cmp.setup({
	snippet = {
		expand = function(args)
			require('luasnip').lsp_expand(args.body)
		end,
	},
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		['<C-b>'] = cmp.mapping.scroll_docs(-4),
		['<C-f>'] = cmp.mapping.scroll_docs(4),
		['<C-Space>'] = cmp.mapping.complete(),
		['<C-e>'] = cmp.mapping.abort(),
		['<Tab>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
	}),
	sources = cmp.config.sources({
		{ name = 'nvim_lsp' },
		-- { name = 'nvim_lsp_document_symbol' },
		-- { name = 'luasnip' },
	}, {
		-- { name = 'buffer' },
	}),
	formatting = {
		format = function(_, vim_item)
			local icons = {
				Text = "",
				Method = "",
				Function = "",
				Constructor = "",
				Field = "ﰠ",
				Variable = "",
				Class = "ﴯ",
				Interface = "",
				Module = "",
				Property = "ﰠ",
				Unit = "塞",
				Value = "",
				Enum = "",
				Keyword = "",
				Snippet = "",
				Color = "",
				File = "",
				Reference = "",
				Folder = "",
				EnumMember = "",
				Constant = "",
				Struct = "פּ",
				Event = "",
				Operator = "",
				TypeParameter = "",
			}
			vim_item.kind = icons[vim_item.kind]
			vim_item.menu = ""
			return vim_item
		end,
		expandable_indicator = false
	},
})

-- Set up lspconfig.
local lsp_flags = {
	debounce_text_changes = 150,
}
local capabilities = require('cmp_nvim_lsp').default_capabilities()
local fmt_augroup = vim.api.nvim_create_augroup("LspFormatting", {})
local on_attach = function(client, bufnr)

	if client.name == "tsserver" then
		-- formatting is handled by prettier
		if require('prettier').config_exists() then
			client.server_capabilities.documentFormattingProvider = false
		end
	elseif client.supports_method("textDocument/formatting") then
		vim.api.nvim_clear_autocmds({ group = fmt_augroup, buffer = bufnr })
		vim.api.nvim_create_autocmd("BufWritePre", {
			group = fmt_augroup,
			buffer = bufnr,
			callback = function()
				vim.lsp.buf.format({ bufnr = bufnr })
			end,
		})
	end

	-- Enable completion triggered by <c-x><c-o>
	vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

	-- Mappings.
	-- See `:help vim.lsp.*` for documentation on any of the below functions
	local buf
	vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
	vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
	vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
	vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
	vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
	vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
	vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
	vim.keymap.set('n', '<space>wl', function()
		print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
	end, bufopts)
	vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
	vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
	vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
	vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
	-- vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
	vim.keymap.set('n', '<F2>', vim.lsp.buf.rename, bufopts)
end


require('lspconfig').clangd.setup {
	capabilities = capabilities,
	on_attach = on_attach,
	flags = lsp_flags,
}

require('lspconfig').tsserver.setup {
	capabilities = capabilities,
	on_attach = on_attach,
	flags = lsp_flags,
}

require('lspconfig').powershell_es.setup {
	capabilities = capabilities,
	on_attach = on_attach,
	flags = lsp_flags,
}

require('lspconfig').sumneko_lua.setup {
	capabilities = capabilities,
	on_attach = on_attach,
	flags = lsp_flags,
	settings = {
		Lua = {
			runtime = {
				version = 'LuaJIT',
			},
			diagnostics = {
				globals = { 'vim' },
			},
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
			},
		},
	},
}

require('lspconfig').angularls.setup {
}

require('lspconfig').tailwindcss.setup {
}

-- require('lspconfig').omnisharp.setup {
-- 	capabilities = capabilities,
-- 	on_attach = on_attach,
-- 	flags = lsp_flags,
--
-- 	-- cmd = { "dotnet", "/path/to/omnisharp/OmniSharp.dll" },
-- 	enable_editorconfig_support = true,
-- 	enable_ms_build_load_projects_on_demand = false,
-- 	enable_roslyn_analyzers = true,
-- 	organize_imports_on_format = true,
-- 	enable_import_completion = true,
-- 	sdk_include_prereleases = true,
-- 	analyze_open_documents_only = false,
-- }

require('lspconfig').ecsact.setup {
	capabilities = capabilities,
	on_attach = on_attach,
	flags = lsp_flags,
}

require('lspconfig').bzl.setup {
	capabilities = capabilities,
	on_attach = on_attach,
	flags = lsp_flags,
}

local rt = require("rust-tools")
rt.setup {
	tools = {
		executor = require("rust-tools.executors").quickfix,
		inlay_hints = {
			auto = false,
			only_current_line = true,
		},
	},
	server = {
		on_attach = function(client, bufnr)
			on_attach(client, bufnr)
			vim.keymap.set("n", "<C-space>", rt.hover_actions.hover_actions, { buffer = bufnr })
			vim.keymap.set("n", "<Leader>a", rt.code_action_group.code_action_group, { buffer = bufnr })
		end,
	},
}
