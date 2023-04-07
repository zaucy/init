local M = {}

local fmt_augroup = vim.api.nvim_create_augroup("LspFormatting", {})

M.on_attach = function(lsp, client, bufnr)
	lsp.default_keymaps({ buffer = bufnr })

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

	if client.name == "omnisharp" then
		client.server_capabilities.semanticTokensProvider.legend = {
			tokenModifiers = { "static" },
			tokenTypes = {
				"comment", "excluded", "identifier", "keyword", "keyword", "number", "operator", "operator",
				"preprocessor", "string", "whitespace", "text", "static", "preprocessor", "punctuation", "string", "string",
				"class", "delegate", "enum", "interface", "module", "struct", "typeParameter", "field", "enumMember", "constant",
				"local", "parameter", "method", "method", "property", "event", "namespace", "label", "xml", "xml", "xml", "xml",
				"xml", "xml", "xml", "xml", "xml", "xml", "xml", "xml", "xml", "xml", "xml", "xml", "xml", "xml", "xml", "xml",
				"xml", "regexp", "regexp", "regexp", "regexp", "regexp", "regexp", "regexp", "regexp", "regexp",
			}
		}
	end
end

return M
