local lsp_flags = {
	debounce_text_changes = 150,
}

require('lspconfig')['tsserver'].setup {
	on_attach = on_attach,
	flags = lsp_flags,
}

require('lspconfig')['rust_analyzer'].setup {
	on_attach = on_attach,
	flags = lsp_flags,
	-- Server-specific settings...
	settings = {
		["rust-analyzer"] = {}
	}
}

